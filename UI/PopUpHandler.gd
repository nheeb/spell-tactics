class_name PopUpHandler extends Control


func _ready() -> void:
	Events.tile_hovered_long.connect(show_tile_popup)
	Events.tile_unhovered_long.connect(hide_tile_popup)

var current_tile: Tile
var screen_pos: Vector2 # target from unprojecting the camera
var prev_screen_pos: Vector2

func show_tile_popup(tile: Tile):
	current_tile = tile
	screen_pos = get_viewport().get_camera_3d().unproject_position(tile.global_position)
	# can use Camera3D.is_position_behind() to check, but should not be relevant here for now	
	#$PopUp.pivot_offset = $PopUp.size / 2.0
	$PopUp.position = screen_pos
	$PopUp.visible = true
	$PopUp.set_text("Tile (%s, %s)" % [tile.r, tile.q])


func hide_tile_popup(tile: Tile):
	$PopUp.visible = false
	current_tile = null
	
#func _physics_process(delta: float) -> void:
	#if current_tile != null:
		#prev_screen_pos = screen_pos
		#screen_pos = get_viewport().get_camera_3d().unproject_position(current_tile.global_position)
		##$PopUp.position = screen_pos
		
func _process(delta: float) -> void:
	if current_tile != null:
		prev_screen_pos = screen_pos
		screen_pos = get_viewport().get_camera_3d().unproject_position(current_tile.global_position)
		$PopUp.position = $PopUp.position.lerp(screen_pos, 0.99)
	#if current_tile != null:  # lerp towards camera to beat this stutter
		#var f = Engine.get_physics_interpolation_fraction()
		#var target_position: Vector2 = prev_screen_pos.lerp(screen_pos, f)
		#$PopUp.position = target_position
