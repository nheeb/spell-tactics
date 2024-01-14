extends Node3D

func _ready() -> void:
	$Level.init_basic_grid(3)
	

var flip := false
func _on_movement_range_button_pressed() -> void:
	if not flip:
		var movement_tiles = $Level.get_all_tiles_in_distance(3, 3, 2)
		$Level._highlight_tile_set(movement_tiles, Highlight.Type.Movement)
		flip = true
	else:
		var movement_tiles = $Level.get_all_tiles_in_distance(3, 3, 2)
		$Level._unhighlight_tile_set(movement_tiles, Highlight.Type.Movement)
		flip = false


var flip2 := false
var ent_type := preload("res://Entities/Environment/Rock.tres")
func _on_entity_find_button_pressed() -> void:
	if not flip2:
		$Level.highlight_entity_type(ent_type)
		flip2 = true
	else:
		$Level.unhighlight_entity_type(ent_type)
		flip2 = false

func _on_nav_button_pressed() -> void:
	var search = $Level.search(Vector2i(0, 6), Vector2i(6, 0))
	search.execute()
	if search.path_found:
		for location in search.path:
			$Level.tiles[location.x][location.y].set_highlight(Highlight.Type.Movement, true)
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
			currently_hovering = null
			
	if currently_hovering and Input.is_action_just_pressed("select"):
		Events.tile_clicked.emit(currently_hovering)


func _on_move_rock_button_pressed() -> void:
	$Level.move_entity($Level.find_entity(ent_type), $Level.tiles[5][4])


func _on_damage_player_pressed() -> void:
	$Level.player.hp -= 1


func _on_save_level_pressed() -> void:
	$Level.save_to_disk("user://level.tres")


func _on_load_level_pressed() -> void:
	$Level.load_from_disk("user://level.tres")
