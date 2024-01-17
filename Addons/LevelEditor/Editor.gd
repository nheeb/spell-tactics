@tool
extends Node
class_name Editor

const LEVEL := preload("res://Logic/Tiles/Level.tscn")

var _level: Level = null

func _ready():
	if not Engine.is_editor_hint():
		return
	_level = LEVEL.instantiate()
	_level.name = 'Level'
	add_child(_level, true)
	_level.clear()
	_level.init_basic_grid(6)

@export var grid_size: int = 6 : set = _set_grid_size, get = _get_grid_size
func _set_grid_size(new_value):
	if grid_size != new_value:
		grid_size = new_value
		_level.clear()
		_level.init_basic_grid(grid_size)

func _get_grid_size():
	return grid_size
