extends OneshotVisualEffect

var start_node: Node3D
var end_node: Node3D
var y_offset := .02
var duration := 2.0

## Quick paste: combat.animation.effect(VFX.LINE, target, {"start_node": , "end_node": , "duration": 2.0})

func effect_start() -> void:
	# Effect Animation goes here
	global_position = Vector3.ZERO
	var im : ImmediateMesh = $MeshInstance3D.mesh as ImmediateMesh
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	im.surface_add_vertex(start_node.global_position + y_offset * Vector3.UP)
	im.surface_add_vertex(end_node.global_position + y_offset * Vector3.UP)
	im.surface_end()
	await VisualTime.new_timer(duration).timeout
	effect_done.emit()
	queue_free()

