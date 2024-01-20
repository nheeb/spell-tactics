@tool
class_name VisualEntity extends Node3D


# Here we could define some common callbacks / signals that other VisualEntities inheriting
# from this could use

## reference to the resource could be needed for variety of effects 
## (e.g. in VisualPrototype for the name)
var type: EntityType

func _enter_tree() -> void:
	if has_node("DebugTile"):
		$DebugTile.visible = false

signal animation_done

func animation_move_to(tile: Tile) -> void:
	var tween := VisualTime.new_tween()
	tween.tween_property(self, "global_position", tile.global_position, 1.0)
	#tween.set_speed_scale(.05)
	await tween.finished
	animation_done.emit()

# TODO discuss this
func update_visuals(entity: Entity):
	pass
	

