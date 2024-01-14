class_name Tile extends Node3D



var entities: Array[Entity] = []
var r: int
var q: int


static func create(r, q) -> Tile:
	# TODO
	return null


func _on_area_3d_mouse_entered() -> void:
	set_highlight(Highlight.Type.Hover, true)
	
func _on_area_3d_mouse_exited() -> void:
	set_highlight(Highlight.Type.Hover, false)
	
func add_entity(entity: Entity):
	entities.append(entity)
	if entity.visual_entity != null:
		$VisualEntities.add_child(entity.visual_entity)
		# TODO add logical entity
		#entity.owner = self
		entity.visual_entity.owner = self
		entity.current_tile = self
		
func remove_entity(entity: Entity):
	var i = entities.find(entity)
	if i == -1:
		printerr("remove_entity(): entity not found")
		return
		
	entities.remove_at(i)
	$VisualEntities.remove_child(entity.visual_entity)
	entity.current_tile = null
	
## Whether player/enemy can move on this. Can move on this if this tile has no entity which is
## an obstacle.
func is_obstacle() -> bool:
	for ent in entities:
		if ent.resource.is_obstacle:
			return true
	return false
	
## Coverage factor for accuracy calculation.
func get_coverage_factor() -> int:
	var factor := 0
	for ent in entities:
		factor = max(factor, ent.resource.cover_value)
	return factor



func set_highlight(type: Highlight.Type, active: bool, _reset_others := false):
	if _reset_others:
		# TODO (if needed)
		pass
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
