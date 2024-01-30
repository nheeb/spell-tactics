@tool
class_name Tile extends Node3D

var entities: Array[Entity] = []
var hovering := false:
	set(h):
		if not h and hovering:
			Events.tile_unhovered_long.emit(self)
		hovering = h

var r: int
var q: int
var location: Vector2i

@onready var level: Level = get_parent()

const TILE = preload("res://Logic/Tiles/Tile.tscn")
static func create(r_tile, q_tile, r_center, q_center) -> Tile:
	# center position is needed to properly align the tile
	var tile = TILE.instantiate()
	var xz_translation: Vector2 = (r_tile-r_center) * Level.Q_BASIS + (q_tile-q_center) * Level.R_BASIS 
	tile.position = Vector3(xz_translation.x, 0.0, xz_translation.y)

	tile.get_node("DebugLabel").text = "(%s, %s)" % [r_tile, q_tile]
	tile.r = r_tile
	tile.q = q_tile
	tile.location = Vector2i(r_tile, q_tile)
	tile.name = "Tile_%02d_%02d" % [r_tile, q_tile]
	return tile
	
## contains at least one drainable entity
func is_drainable():
	for ent in entities:
		if ent.type.is_drainable:
			return true
	return false

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
		printerr("remove_entity(): entity not found")
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
func is_obstacle() -> bool:
	for ent in entities:
		if ent.type.is_obstacle:
			return true
	return false

func is_blocked() -> bool:
	return is_obstacle() or entities.any(func(e): return e.type.is_blocker)

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
	Events.tile_hovered_long.emit(self)
	#print("Hovered tile %d, %d" % [r, q])

func _to_string() -> String:
	return name

func distance_to(other_tile: Tile) -> int:
	return Utility.tile_distance(self, other_tile)

func get_surrounding_tiles(_range := 1) -> Array[Tile]:
	return level.get_all_tiles_in_distance_of_tile(self, _range)
