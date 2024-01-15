class_name PopUps extends Control


func _ready() -> void:
	Events.tile_hovered_long.connect(show_popup)
	Events.tile_unhovered_long.connect(hide_popup)

var current_tile: Tile

func show_popup(tile: Tile):
	current_tile = tile
	var screen_pos: Vector2 = get_viewport().get_camera_3d().unproject_position(tile.global_position)
	# can use Camera3D.is_position_behind() to check, but should not be relevant here for now	
	#$PopUp.pivot_offset = $PopUp.size / 2.0
	$PopUp.position = screen_pos
	$PopUp.visible = true
	$PopUp/PanelContainer/MarginContainer/Label.text = "Tile (%s, %s)" % [tile.r, tile.q]
	

func _process(delta: float):
	if current_tile != null:
		var screen_pos: Vector2 = get_viewport().get_camera_3d().unproject_position(current_tile.global_position)
		$PopUp.position = screen_pos

func hide_popup(tile: Tile):
	$PopUp.visible = false
