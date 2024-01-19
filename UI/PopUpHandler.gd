class_name PopUpHandler extends Control

@export var viewport: Viewport

func _ready() -> void:
	Events.tile_hovered_long.connect(show_tile_popup)
	Events.tile_unhovered_long.connect(hide_tile_popup)

var current_tile: Tile
var screen_pos: Vector2 # target from unprojecting the camera
var prev_screen_pos: Vector2

#const POPUP = preload("res://UI/PopUp.tscn")
func show_tile_popup(tile: Tile):
	#var popup = POPUP.instantiate()
	var popup = $PopUp
	popup.name = "PopUp"
	#add_child(popup)
	current_tile = tile
	screen_pos = viewport.get_camera_3d().unproject_position(tile.global_position)
	# can use Camera3D.is_position_behind() to check, but should not be relevant here for now	
	#$PopUp.pivot_offset = $PopUp.size / 2.0
	popup.position = screen_pos
	popup.show()
	popup.show_tile(tile)
	#queue_redraw()


func hide_tile_popup(tile: Tile):
	current_tile = null
	$PopUp.hide_popup()
	#$PopUp.hide()
	
#func _physics_process(delta: float) -> void:
	#if current_tile != null:
		#prev_screen_pos = screen_pos
		#screen_pos = get_viewport().get_camera_3d().unproject_position(current_tile.global_position)
		##$PopUp.position = screen_pos
		
func _process(delta: float) -> void:
	if current_tile != null:
		prev_screen_pos = screen_pos
		screen_pos = viewport.get_camera_3d().unproject_position(current_tile.global_position)
		$PopUp.position = $PopUp.position.lerp(screen_pos, 0.99)
	#if current_tile != null:  # lerp towards camera to beat this stutter
		#var f = Engine.get_physics_interpolation_fraction()
		#var target_position: Vector2 = prev_screen_pos.lerp(screen_pos, f)
		#$PopUp.position = target_position
