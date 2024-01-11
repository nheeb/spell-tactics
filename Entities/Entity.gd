class_name Entity extends Node3D

@export var internal_name: String
@export var pretty_name: String
@export_multiline var fluff_text: String
@export var energy: Array[Game.Energy]

func _init() -> void:
	$DebugTile.queue_free()
