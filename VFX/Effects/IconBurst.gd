extends OneshotVisualEffect

var icon_name : String = ""
var color := Color.WHITE
var duration := 2.0

func effect_start() -> void:
	if icon_name != "":
		$GPUParticles3D.draw_pass_1.material.albedo_texture = load("res://Assets/Sprites/Icons/%s.png" % icon_name)
	$GPUParticles3D.draw_pass_1.material.albedo_color = color
	
	$GPUParticles3D.emitting = true
	
	await VisualTime.new_timer(duration).timeout
	
	effect_done.emit()
