class_name LevelPath extends MeshInstance3D

@export var length: float = 1.0 : set = _set_length, get = _get_length
func _set_length(new_value):
	if length != new_value:
		length = new_value
		mesh.size.y = new_value

func _get_length():
	return length
	
func _ready():
	pass # Replace with function body.


func _process(delta):
	pass
