extends StayingVisualEffect

# Quick Copy Paste: 
# combat.animation.add_staying_effect(VFX.ICON_VISUALS, entity.visual_entity, "??", {"icon_name": "", "color": Color. })

var icon_name : String = ""
var color := Color.WHITE

func effect_start() -> void:
	if icon_name != "":
		$GPUParticles3D.draw_pass_1.material.albedo_texture = load("res://Assets/Sprites/Icons/%s.png" % icon_name)
	$GPUParticles3D.draw_pass_1.material.albedo_color = color
	effect_done.emit()
	
func on_effect_end() -> void:
	# death animation here
	effect_died.emit()
	queue_free()
