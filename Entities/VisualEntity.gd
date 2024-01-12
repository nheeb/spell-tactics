class_name VisualEntity extends Node3D


# Here we could define some common callbacks / signals that other VisualEntities inheriting
# from this could use

func _ready() -> void:
	$DebugTile.visible = false
