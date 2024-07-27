extends Node2D


func test_func():
	pass
	
	
func _ready() -> void:
	self.get("test_func").call()
