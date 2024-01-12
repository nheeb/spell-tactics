extends Node3D


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
var ent_type := preload("res://Entities/Types/Rock.tres")
func _on_entity_find_button_pressed() -> void:
	if not flip2:
		$TileGrid.highlight_entity_type(ent_type)
		flip2 = true
	else:
		var movement_tiles = $TileGrid.get_all_tiles_in_distance(3, 3, 2)
		$TileGrid.unhighlight_entity_type(ent_type)
		flip2 = false



@onready var mouse_ray = %MouseRaycast
func _physics_process(delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	var camera := get_viewport().get_camera_3d()
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)
	var ray_length := camera.far
	var end := ray_origin + ray_direction * ray_length
	mouse_ray.target_position = mouse_ray.to_local(end)
	
	if mouse_ray.is_colliding():
		#print(mouse_ray.get_collider())
		pass
