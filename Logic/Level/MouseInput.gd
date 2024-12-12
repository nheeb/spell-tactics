class_name MouseInput extends RayCast3D

static var mouse_block: Block = Block.new()

# A reference to cards3d is needed here to see if the hover/click input is meant for this RayCast
# or the one in Cards3D (cards3d has priority, since it is "on top" visually)
var cards3d: Cards3D = null
# for checking current GamePhase
var combat: Combat

var disabled := false

const BasicMovement = preload("res://Content/Actives/BasicMovement.tres")
func get_highlight_type() -> Highlight.Type:

	if combat.input.current_castable != null and combat.input.current_castable.get_type() == BasicMovement:
		return Highlight.Type.HoverAction
	elif targeting:
		return Highlight.Type.HoverTarget
	else:
		return Highlight.Type.Hover

var targeting: bool = false
func hover_tile(tile: Tile):
	if mouse_block.is_blocked():
		return
	if combat != null:  # check if targeting with a spell
		targeting = combat.current_phase == Combat.RoundPhase.Spell \
					and combat.input.current_castable

	tile.set_highlight(get_highlight_type(), true)
	PAHoverTile.on_tile_hovered.emit(tile)  # alternativ: PaHoverTile.new(), combat.trigger_action(PaHoverTile.new(args))
	tile.get_node("HoverTimer").start()
	
func unhover_tile(tile: Tile):
	tile.set_highlight(Highlight.Type.Hover, false)
	tile.set_highlight(Highlight.Type.HoverTarget, false)
	tile.set_highlight(Highlight.Type.HoverAction, false)
	if tile.hovering:
		tile.hovering = false
		if combat != null:
			combat.action_stack.process_player_action(PAHoverTileLong.new(tile, false))
	tile.get_node("HoverTimer").stop()
	Events.tile_unhovered.emit(tile)


var currently_hovering: Tile = null
func _process(delta: float) -> void:
	var mouse_position := Utility.get_mouse_pos_absolute()
	var camera: Camera3D = %Camera3D
	var ray_origin := camera.project_ray_origin(mouse_position)

	var ray_direction := camera.project_ray_normal(Utility.scale_screen_pos(mouse_position))
	var end := ray_origin + ray_direction * camera.far
	self.target_position = to_local(end)
	
	# TODO to really polish this tile hovering it would be nice to send a raycast every frame.
	#  makes it feel snappier. Though the RayCast3D node sends every physics frame.
	#  So this change would entail sending the raycast from code instead.
	
	# if something has been hit and hasn't been hit in Cards3D as well
	if is_colliding() and (cards3d == null or not cards3d.raycast_hit) and not disabled:
		var collider = get_collider()
		if collider is Area3D:
			if collider.is_in_group("tile_area"):
				var tile3d: Tile3D = collider.get_parent()
				var tile: Tile = tile3d.tile
				if currently_hovering != null and currently_hovering != tile:
					unhover_tile(currently_hovering)
				if tile != currently_hovering:
					hover_tile(tile)
				currently_hovering = tile
	else:
		if currently_hovering != null:
			unhover_tile(currently_hovering)
			currently_hovering = null
			
	if currently_hovering and Input.is_action_just_pressed("select") and not mouse_block.is_blocked():
		#var connections = Events.tile_clicked.get_connections()
		Events.tile_clicked.emit(currently_hovering)
	
	if currently_hovering and Input.is_action_just_released("select"):
		Events.tile_click_released.emit(currently_hovering)
	
	if currently_hovering and Input.is_action_just_pressed("deselect") and not mouse_block.is_blocked():
		Events.tile_rightclicked.emit(currently_hovering)
