extends Node3D

# Quick Paste: combat.animation.effect(VFX.HEX_RINGS, target, {"color": Color.})

signal effect_done

var color: Color = Color.HOT_PINK
var duration := 1.6

func effect_start() -> void:
	$OmniLight3D.light_color = color
	$MeshInstance3D.material_override.set("shader_parameter/albedo", color)
	var tween := VisualTime.new_tween()
	tween.tween_property($MeshInstance3D.material_override, "shader_parameter/progress", 1.0, duration).from(0.0)
	tween.tween_property($OmniLight3D, "light_energy", 0.0, duration)
	await tween.finished
	effect_done.emit()
	queue_free()
