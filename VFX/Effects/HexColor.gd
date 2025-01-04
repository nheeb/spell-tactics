extends OneshotVisualEffect

var color: Color = Color.RED
var duration := 1.6
var alpha := .2

func effect_start() -> void:
	$MeshInstance3D.material_override.set("albedo_color", color)
	var tween := VisualTime.new_tween()
	tween.tween_property($MeshInstance3D.material_override, "albedo_color:a", alpha, duration * .5).from(0.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($MeshInstance3D.material_override, "albedo_color:a", 0.0, duration * .5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	effect_done.emit()
	queue_free()
