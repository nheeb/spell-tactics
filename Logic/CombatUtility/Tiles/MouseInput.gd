extends RayCast3D


# A reference to cards3d is needed here to see if the hover/click input is meant for this RayCast
# or the one in Cards3D (cards3d has priority, since it is "on top" visually)
var cards3d: Cards3D = null
# for checking current GamePhase
var combat: Combat

var disabled := false

var targeting: bool = false
func enable_highlight(tile: Tile):
	if combat != null:  # check if targeting with a spell
		if combat.current_phase == Combat.RoundPhase.Spell:
			var spell_phase = combat.get_phase_node(combat.current_phase)
			if spell_phase.state == SpellPhase.CastingState.Targeting:
				targeting = true
			else:
				targeting = false
		else:
			targeting = false
		
	tile.set_highlight(Highlight.Type.HoverTarget if targeting else Highlight.Type.Hover, true)
	Events.tile_hovered.emit(tile)
	tile.get_node("HoverTimer").start()
	
func disable_highlight(tile: Tile):
	tile.set_highlight(Highlight.Type.Hover, false)
	tile.set_highlight(Highlight.Type.HoverTarget, false)
	tile.hovering = false
	tile.get_node("HoverTimer").stop()
	Events.tile_unhovered.emit(tile)


var currently_hovering: Tile = null
func _physics_process(delta: float) -> void:	
	var mouse_position := Utility.get_mouse_pos_absolute()
	var camera: Camera3D = %Camera3D
	var ray_origin := camera.project_ray_origin(mouse_position)

	var ray_direction := camera.project_ray_normal(Utility.scale_screen_pos(mouse_position))
	var end := ray_origin + ray_direction * camera.far
	self.target_position = to_local(end)
	
	# if something has been hit and hasn't been hit in Cards3D as well
	if is_colliding() and (cards3d == null or not cards3d.raycast_hit) and not disabled:
		var collider = get_collider()
		if collider is Area3D:
			if collider.is_in_group("tile_area"):
				var tile: Tile = collider.get_parent()
				if tile != currently_hovering:
					enable_highlight(tile)
				
				if currently_hovering != null and currently_hovering != tile:
					disable_highlight(currently_hovering)

				currently_hovering = tile
	else:
		if currently_hovering != null:
			disable_highlight(currently_hovering)
			currently_hovering = null
			
	if currently_hovering and Input.is_action_just_pressed("select"):
		var connections = Events.tile_clicked.get_connections()
		Events.tile_clicked.emit(currently_hovering)