extends Node3D

func _ready() -> void:
	pass
	

var flip := false
func _on_movement_range_button_pressed() -> void:
	if not flip:
		var movement_tiles = $TileGrid.get_all_tiles_in_distance(3, 3, 2)
		$TileGrid._highlight_tile_set(movement_tiles, Highlight.Type.Movement)
		flip = true
	else:
		var movement_tiles = $TileGrid.get_all_tiles_in_distance(3, 3, 2)
		$TileGrid._unhighlight_tile_set(movement_tiles, Highlight.Type.Movement)
		flip = false


var flip2 := false
var ent_type := preload("res://Entities/Environment/Rock.tres")
func _on_entity_find_button_pressed() -> void:
	if not flip2:
		$TileGrid.highlight_entity_type(ent_type)
		flip2 = true
	else:
		$TileGrid.unhighlight_entity_type(ent_type)
		flip2 = false

func _on_nav_button_pressed() -> void:
	var search = $TileGrid.search(Vector2i(0, 6), Vector2i(6, 0))
	search.execute()
	print(search.path)

@onready var mouse_ray := %MouseRaycast
var currently_hovering: Tile = null
func _physics_process(delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	var camera := get_viewport().get_camera_3d()
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)
	var end := ray_origin + ray_direction * camera.far
	mouse_ray.target_position = mouse_ray.to_local(end)
	
	if mouse_ray.is_colliding():
		var collider = mouse_ray.get_collider()
		if collider is Area3D:
			if collider.is_in_group("tile_area"):
				var tile: Tile = collider.get_parent()
				if tile != currently_hovering:
					tile.set_highlight(Highlight.Type.Hover, true)
					Events.tile_hovered.emit(tile)
				
				if currently_hovering != null and currently_hovering != tile:
					currently_hovering.set_highlight(Highlight.Type.Hover, false)
					Events.tile_unhovered.emit(currently_hovering)
					currently_hovering = null
				currently_hovering = tile
	else:
		if currently_hovering != null:
			currently_hovering.set_highlight(Highlight.Type.Hover, false)
			Events.tile_unhovered.emit(currently_hovering)
			currently_hovering == null
			
	if currently_hovering and Input.is_action_just_pressed("select"):
		Events.tile_clicked.emit(currently_hovering)
