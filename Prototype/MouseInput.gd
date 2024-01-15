extends RayCast3D

var currently_hovering: Tile = null
func _physics_process(delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	var camera := get_viewport().get_camera_3d()
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)
	var end := ray_origin + ray_direction * camera.far
	self.target_position = to_local(end)
	
	if is_colliding():
		var collider = get_collider()
		if collider is Area3D:
			if collider.is_in_group("tile_area"):
				var tile: Tile = collider.get_parent()
				if tile != currently_hovering:
					tile.set_highlight(Highlight.Type.Hover, true)
					Events.tile_hovered.emit(tile)
					tile.get_node("HoverTimer").start()
				
				if currently_hovering != null and currently_hovering != tile:
					currently_hovering.set_highlight(Highlight.Type.Hover, false)
					currently_hovering.hovering = false
					currently_hovering.get_node("HoverTimer").stop()
					Events.tile_unhovered.emit(currently_hovering)
					
				currently_hovering = tile
	else:
		if currently_hovering != null:
			currently_hovering.set_highlight(Highlight.Type.Hover, false)
			currently_hovering.get_node("HoverTimer").stop()
			currently_hovering.hovering = false
			Events.tile_unhovered.emit(currently_hovering)
			currently_hovering = null
			
	if currently_hovering and Input.is_action_just_pressed("select"):
		Events.tile_clicked.emit(currently_hovering)
