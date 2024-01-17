@tool
class_name EditorUI extends Control

var tool_pencil = Pencil.new()
var tool_raise = Raise.new()
var tool_lower = Lower.new()

var tool_active = tool_pencil

func _on_pencil_pressed():
	tool_active = tool_pencil	

func _on_raise_pressed():
	tool_active = tool_raise	

func _on_lower_pressed():
	tool_active = tool_lower

