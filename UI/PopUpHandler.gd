class_name PopUpHandler extends Control

@export var viewport: Viewport

@onready var popup

const POPUP = preload("res://UI/PopUp.tscn")
var current_tile: Tile
var screen_pos: Vector2 # target from unprojecting the camera
var prev_screen_pos: Vector2


func _ready() -> void:
	Events.tile_hovered_long.connect(show_tile_popup)
	Events.tile_unhovered_long.connect(hide_tile_popup)
	popup = POPUP.instantiate()


func show_tile_popup(tile: Tile):
	#var popup = POPUP.instantiate()
	current_tile = tile
	# can use Camera3D.is_position_behind() to check, but should not be relevant here for now	
	screen_pos = viewport.get_camera_3d().unproject_position(tile.global_position)
	
	if not popup.is_inside_tree():
		add_child(popup)
	else:
		printerr("trying to show 2nd popup while 1st still showing")
	popup.position = screen_pos
	popup.show_tile(tile)
	#queue_redraw()


func hide_tile_popup(tile: Tile):

	if popup.is_inside_tree():
		remove_child(popup)
	else:
		printerr("weird not inside tree")
	current_tile = null
	
	popup.hide_popup()
	#popup.queue_free()
	
#func _physics_process(delta: float) -> void:
	#if current_tile != null:
		#prev_screen_pos = screen_pos
		#screen_pos = get_viewport().get_camera_3d().unproject_position(current_tile.global_position)
		##$PopUp.position = screen_pos

const threshold: float = .1
func _process(delta: float) -> void:
	if current_tile != null:
		prev_screen_pos = screen_pos
		screen_pos = viewport.get_camera_3d().unproject_position(current_tile.global_position)
		if prev_screen_pos.distance_to(screen_pos) > threshold:
			popup.position = screen_pos
	#if current_tile != null:  # lerp towards camera to beat this stutter
		#var f = Engine.get_physics_interpolation_fraction()
		#var target_position: Vector2 = prev_screen_pos.lerp(screen_pos, f)
		#$PopUp.position = target_position
