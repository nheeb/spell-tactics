extends StayingVisualEffect

var color: Color = Color.RED
var duration := .25
var alpha := .2

func toggle_active(active: bool) -> void:
	var alpha_start := 0.0 if active else alpha
	var alpha_end := alpha if active else 0.0
	var tween := VisualTime.new_tween()
	tween.tween_property($MeshInstance3D.material_override, "albedo_color:a", alpha_end, duration) \
		.from(alpha_start).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.finished

func effect_start() -> void:
	$MeshInstance3D.material_override.set("albedo_color", color)
	await toggle_active(true)
	effect_done.emit()

func on_effect_end() -> void:
	await toggle_active(false)
	effect_died.emit()
	queue_free()
