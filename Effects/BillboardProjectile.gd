extends OneshotVisualEffect

var texture_name := ""
var target : Node3D
var speed := 6.0
var height := 1.0

## Quick Paste: combat.animation.effect(VFX.BILLBOARD_PROJECTILE, origin, {"texture_name": , "target": })

func effect_start() -> void:
	$MeshInstance3D.position.y = height
	if texture_name:
		var texture := load("res://Assets/Sprites/Effects/" + texture_name + ".png")
		$MeshInstance3D.material_override.albedo_texture = texture
	
	if target:
		var tween := VisualTime.new_tween()
		var duration := global_position.distance_to(target.global_position) / speed
		tween.tween_property($MeshInstance3D, "global_position", target.global_position, duration)
		await tween.finished
	
	effect_done.emit()
	queue_free()

