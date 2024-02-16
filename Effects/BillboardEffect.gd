extends OneshotVisualEffect

var texture_name := ""
var duration := 2.0
var alpha_blend_time := .4
var start_size := 1.0
var grow_size := 1.0
var height := 1.0

func effect_start() -> void:
	$MeshInstance3D.position.y = height
	$MeshInstance3D.scale = Vector3.ONE * start_size
	if texture_name:
		var texture := load("res://Assets/Sprites/Effects/" + texture_name + ".png")
		$MeshInstance3D.material_override.albedo_texture = texture
	
	var grow_tween := VisualTime.new_tween()
	grow_tween.tween_property($MeshInstance3D, "scale", Vector3.ONE * grow_size, duration)
	
	$MeshInstance3D.material_override.get("albedo_color").a = 0.0
	
	var alpha_tween := VisualTime.new_tween()
	alpha_tween.tween_property($MeshInstance3D.material_override, "albedo_color:a", 1.0, alpha_blend_time)
	alpha_tween.tween_interval(duration - 2* alpha_blend_time)
	alpha_tween.tween_property($MeshInstance3D.material_override, "albedo_color:a", 0.0, alpha_blend_time)
	
	await grow_tween.finished
	
	effect_done.emit()
	queue_free()

