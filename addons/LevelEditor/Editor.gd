extends Node
class_name LevelEditor

const LEVEL = preload("res://Logic/Tiles/Level.tscn")

var level: Level = null

func _ready():
	if not Engine.is_editor_hint():
		return
	level = LEVEL.instantiate()
	level.name = 'Level'
	add_child(level, true)
	level.clear()
	level.init_basic_grid(6)

@export var grid_size: int = 6 : set = _set_grid_size, get = _get_grid_size
func _set_grid_size(new_value):
	if grid_size != new_value:
		grid_size = new_value
		if level != null:
			level.clear()
			level.init_basic_grid(grid_size)

func _get_grid_size():
	return grid_size
