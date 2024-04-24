extends Control

signal save_game_pressed(id)
signal load_game_pressed(id)

func _on_save_level_pressed() -> void:
	save_game_pressed.emit(str(int(%SaveID.value)))


func _on_load_level_pressed() -> void:
	load_game_pressed.emit(str(int(%SaveID.value)))

@onready var save_load_menu := %SaveLoadMenu

func _on_save_load_game_pressed() -> void:
	%SaveLoadMenu.setup()


func _on_show_debug_pressed() -> void:
	%List.visible = not %List.visible
