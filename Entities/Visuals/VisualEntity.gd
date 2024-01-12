class_name VisualEntity extends Node3D


# Here we could define some common callbacks / signals that other VisualEntities inheriting
# from this could use

## reference to the resource could be needed for variety of effects 
## (e.g. in VisualPrototype for the name)
var type: EntityType

func _enter_tree() -> void:
	$DebugTile.visible = false
