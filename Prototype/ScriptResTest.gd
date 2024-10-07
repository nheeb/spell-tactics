extends Node3D

var x := {}

func _ready() -> void:
	var a = x.get_or_add("test", [])
	a.append(1)
	print(x)
