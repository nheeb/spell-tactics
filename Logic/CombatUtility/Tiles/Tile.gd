class_name Tile extends Node3D

var entities: Array[Entity] = []
var hovering := false

var r: int
var q: int
var location: Vector2i: 
	set(l):
		push_error("setting location is forbidden.")
	get():
		return Vector2i(r, q)

@onready var level: Level = get_parent() as Level
var combat: Combat:
	get:
		return level.combat
@onready var highlight: Highlight = $Highlight

const TILE = preload("res://Logic/CombatUtility/Tiles/Tile.tscn")
static func create(r_tile, q_tile, r_center, q_center) -> Tile:
	# center position is needed to properly align the tile
	var tile = TILE.instantiate()
	var xz_translation: Vector2 = (r_tile-r_center) * Level.Q_BASIS + (q_tile-q_center) * Level.R_BASIS 
	tile.position = Vector3(xz_translation.x, 0.0, xz_translation.y)

	tile.get_node("DebugLabel").text = "(%s, %s)" % [r_tile, q_tile]
	tile.r = r_tile
	tile.q = q_tile
	tile.name = "Tile_%02d_%02d" % [r_tile, q_tile]
	return tile
	
## contains at least one drainable entity
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

func get_drainable_energy_in_range(_range := 1) -> EnergyStack:
	var energy := get_drainable_energy()
	for t in get_surrounding_tiles(_range):
		energy.add(t.get_drainable_energy())
	return energy

func _on_area_3d_mouse_entered() -> void:
	set_highlight(Highlight.Type.Hover, true)
	
func _on_area_3d_mouse_exited() -> void:
	set_highlight(Highlight.Type.Hover, false)

func has_entity(entity_type: EntityType):
	return entities.any(func(entity: Entity): return entity.type == entity_type)

func add_entity(entity: Entity):
	entity.current_tile = self
	entities.append(entity)

func remove_entity(entity: Entity):
	var i = entities.find(entity)
	if i == -1:
		push_error("remove_entity(): entity not found")
		return
	
	entities.remove_at(i)

	entity.current_tile = null
	# should we turn it invisible then? huh
	#entity.visual_entity.visible = false
	
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
	
	
## Whether player/enemy can move on this. Can move on this if this tile has no entity which is
## an obstacle.
func is_obstacle(mask: int = Constants.INT64_MAX) -> bool:
	var mask_aggregate: int = 0
	for ent in entities:
		mask_aggregate = mask_aggregate | ent.type.obstacle_layer
	return (mask & mask_aggregate) > 0

func is_blocked() -> bool:
	return is_obstacle(Constants.INT64_MAX) or entities.any(func(e): return e.type.is_blocker)

## Coverage factor for accuracy calculation.
func get_coverage_factor() -> int:
	var factor := 0
	for ent in entities:
		factor = max(factor, ent.resource.cover_value)
	return factor

func set_highlight(type: Highlight.Type, active: bool):
	if active:
		$Highlight.enable_highlight(type)
	else:
		$Highlight.disable_highlight(type)

func serialize() -> TileState:
	var tile_state := TileState.new()
	tile_state.r = r
	tile_state.q = q
	var entity_states: Array[EntityState] = []
	
	for entity: Entity in self.entities:
		entity_states.append(entity.serialize())
	
	tile_state.entities = entity_states
	return tile_state

func _on_hover_timer_timeout() -> void:
	hovering = true
	combat.action_stack.process_player_action(PAHoverTileLong.new(self, true))

## SUBACTION
func _hover_long(h: bool) -> void:
	if h:
		Events.tile_hovered_long.emit(self)
	else:
		Events.tile_unhovered_long.emit(self)
	for e in entities:
		await e.on_hover_long(h)

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

func _to_string() -> String:
	return name

func distance_to(other_tile: Tile) -> int:
	return Utility.tile_distance(self, other_tile)

func is_next_to(other_tile: Tile) -> bool:
	return distance_to(other_tile) == 1

func direction_to(other_tile: Tile) -> Vector2i:
	var line := level.get_line(self, other_tile)
	if len(line) == 0:
		return Vector2i.ZERO
	var step := line[0]
	return step.location - self.location

const DIRECTION_ORDER = [Vector2i(0, 1),Vector2i(-1, 1),Vector2i(-1, 0),Vector2i(0, -1),Vector2i(1, -1),Vector2i(1, 0)]
static func rotate_direction_clockwise(direction: Vector2i, x := 1) -> Vector2i:
	return DIRECTION_ORDER[ ( x+DIRECTION_ORDER.find(direction) ) % len(DIRECTION_ORDER)]

func step_in_direction(direction: Vector2i) -> Tile:
	return level.get_tile_by_location(location + direction)

func get_surrounding_tiles(_range := 1) -> Array[Tile]:
	return level.get_all_tiles_in_distance_of_tile(self, _range)

func get_reference() -> TileReference:
	return TileReference.new(location)
