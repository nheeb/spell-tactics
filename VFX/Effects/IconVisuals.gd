extends StayingVisualEffect

# Quick Copy Paste: 
# combat.animation.add_staying_effect(VFX.ICON_VISUALS, entity.visual_entity, "??", \
# 	{"icon_name": "", "color": Color. , "quad": true})

var icon_texture: Texture
var icon: Texture:
	set (i):
		icon_texture = i
	get:
		return icon_texture
var icon_name: String = ""
var color := Color.WHITE
var quad := false

func effect_start() -> void:
	$Quad.visible = quad
	$GPUParticles3D.visible = not quad
	if not icon_texture:
		if icon_name != "":
			icon_texture = load("res://Assets/Sprites/Icons/%s.png" % icon_name)
	if icon_texture:
		$GPUParticles3D.draw_pass_1.material.albedo_texture = icon_texture
		$Quad.material_override.albedo_texture = icon_texture
	$Quad.material_override.albedo_color = color
	$GPUParticles3D.draw_pass_1.material.albedo_color = color
	effect_done.emit()
	
func on_effect_end() -> void:
	# death animation here
	effect_died.emit()
	queue_free()
