class_name Tile extends CombatObject

# TODO these are not yet connected -- maybe this makes more sense to put into tile?
signal drainable_hovered
signal drainable_unhovered

var entities: Array[Entity] = []
var hovering := false

@export var r: int
@export var q: int
var location: Vector2i:
	set(l):
		push_error("setting location is forbidden.")
	get():
		return Vector2i(r, q)
var tile3d: Tile3D:
	set(x):
		node3d = x
	get:
		return node3d as Tile3D
var highlight: Highlight:
	get:
		return tile3d.highlight

#####################################
## Creation & CombatObject Methods ##
#####################################

const TILE_3D = preload("res://Logic/Level/Tile3D.tscn")
## Create a new Tile along with tile3d
static func create(r_tile: int, q_tile: int, r_center: float, q_center: float) -> Tile:
	var tile := Tile.new()
	var tile_3d = TILE_3D.instantiate()
	tile_3d._ready()
	# center position is needed to properly align the tile
	var xz_translation: Vector2 = (r_tile-r_center) * Level.Q_BASIS \
								+ (q_tile-q_center) * Level.R_BASIS 
	tile_3d.position = Vector3(xz_translation.x, 0.0, xz_translation.y)
	tile_3d.get_node("DebugLabel").text = "(%s, %s)" % [r_tile, q_tile]
	tile_3d.name = "Tile_%02d_%02d" % [r_tile, q_tile]
	
	tile.r = r_tile
	tile.q = q_tile
	tile.tile3d = tile_3d
	tile_3d.tile = tile
	
	return tile

func serialize() -> TileState:
	var tile_state := TileState.new(self)
	var entity_states: Array[EntityState] = []
	
	for entity: Entity in self.entities:
		entity_states.append(entity.serialize())
	
	tile_state.entity_states = entity_states
	return tile_state

func get_name() -> String:
	return "Tile(%02d/%02d)" % [r, q]

############################
## Entity Related Methods ##
############################

func has_entity_type(entity_type: EntityType):
	return entities.any(func(entity: Entity): return entity.type == entity_type)

func add_entity(entity: Entity):
	entity.current_tile = self
	entities.append(entity)
	if entity.visual_entity:
		if entity.visual_entity.get_parent() == null:
			combat.level.visual_entities.add_child(entity.visual_entity)
			entity.visual_entity.owner = combat.level
			entity.visual_entity.position = position

func remove_entity(entity: Entity):
	var i := entities.find(entity)
	if i == -1:
		push_error("remove_entity(): entity not found")
		return
	entities.remove_at(i)
	entity.current_tile = null
	
## Returns all enemy entities on this tile.
func get_enemies() -> Array[EnemyEntity]:
	var enemies: Array[EnemyEntity] = []
	for ent in entities:
		if ent is EnemyEntity:
			enemies.append(ent)
	return enemies

## Whether it contains at least one EnemyEntity
func has_enemy() -> bool:
	for ent in entities:
		if ent is EnemyEntity:
			return true
	return false

## Contains at least one drainable entity
func is_drainable() -> bool:
	for ent in entities:
		if ent.type.is_drainable and not ent.energy.is_empty():
			return true
	return false

func get_drainable_entities() -> Array[Entity]:
	var ents: Array[Entity] = []
	for ent in entities:
		if ent.type.is_drainable:
			ents.append(ent)
	return ents

func get_drainable_energy() -> EnergyStack:
	var drainable_e: EnergyStack = EnergyStack.new()
	for ent in get_drainable_entities():
		drainable_e.add(ent.energy)
	return drainable_e

func get_highest_cover() -> int:
	return entities.reduce(
		func (accum: int, ent: Entity) -> int:
			if not ent.type.has_hp:
				return accum
			return max(accum, ent.cover)
			, 0)

func get_entities_with_highest_cover() -> Array[Entity]:
	var hightest_cover := get_highest_cover()
	return entities.filter(
		func (e: Entity):
			return e.cover == hightest_cover
	)

## Whether player/enemy can move on this. Can move on this if this tile has no entity which is
## an obstacle.
func is_obstacle(mask: int = Constants.INT64_MAX) -> bool:
	var mask_aggregate: int = 0
	for ent in entities:
		mask_aggregate = mask_aggregate | ent.type.obstacle_layer
	return (mask & mask_aggregate) > 0

func is_blocked() -> bool:
	return is_obstacle(Constants.INT64_MAX) or entities.any(func(e): return e.type.is_blocker)

## Returns the combined obstacle layers of this tile's entities
func get_obstacle_layers() -> int:
	var layers: int = 0
	for ent in entities:
		layers |= ent.type.obstacle_layer
	return layers

func get_tags() -> Array[String]:
	var tags : Array[String] = []
	for e in entities:
		for t in e.get_tags():
			if not t in tags:
				tags.append(t)
	return tags

#######################
## Hover & Highlight ##
#######################

func set_highlight(type: Highlight.Type, active: bool):
	tile3d.set_highlight(type, active)

## ACTION
func _hover_long(h: bool) -> void:
	if h:
		Events.tile_hovered_long.emit(self)
	else:
		Events.tile_unhovered_long.emit(self)
	for e in entities:
		await e.on_hover_long(h)

#########################
## Hex Tile Navigation ##
#########################

func distance_to(other_tile: Tile) -> int:
	return Utility.rq_distance(self.r, self.q, other_tile.r, other_tile.q)

func is_next_to(other_tile: Tile) -> bool:
	return distance_to(other_tile) == 1

func direction_to(other_tile: Tile) -> Vector2i:
	var line := combat.level.get_line(self, other_tile)
	if len(line) == 0:
		return Vector2i.ZERO
	var step := line[0]
	return step.location - self.location

const DIRECTION_ORDER = [Vector2i(0, 1),Vector2i(-1, 1),Vector2i(-1, 0),Vector2i(0, -1),Vector2i(1, -1),Vector2i(1, 0)]
static func rotate_direction_clockwise(direction: Vector2i, x := 1) -> Vector2i:
	return DIRECTION_ORDER[ ( x+DIRECTION_ORDER.find(direction) ) % len(DIRECTION_ORDER)]

func step_in_direction(direction: Vector2i) -> Tile:
	return combat.level.get_tile_by_location(location + direction)

func get_surrounding_tiles(_range := 1) -> Array[Tile]:
	return combat.level.get_all_tiles_in_distance_of_tile(self, _range)

func get_tiles_in_walking_range(_range: int) -> Array[Tile]:
	return get_surrounding_tiles(_range).filter(
		func (t: Tile):
			if t.is_blocked():
				return false
			var walking_dist := self.get_walking_distance(t)
			return walking_dist > 0 and walking_dist <= _range
	)

func get_walking_distance(other_tile: Tile) -> int:
	return combat.level.get_shortest_distance(self, other_tile)

func get_line(other_tile: Tile) -> Array[Tile]:
	return combat.level.get_line(self, other_tile)

################
## DEPRECATED ##
################

# Dirty solution for now
func get_node(x):
	return node3d.get_node(x)
