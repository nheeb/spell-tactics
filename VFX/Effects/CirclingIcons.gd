extends StayingVisualEffect

# Quick Copy Paste: 
# combat.animation.add_staying_effect(VFX.ICON_CYCLE, entity.visual_entity, "??", \
# 	{"icon_name": "", "color": Color.})

var icon_texture: Texture
var icon: Texture:
	set (i):
		icon_texture = i
	get:
		return icon_texture
var icon_name: String = "":
	set (_icon_name):
		icon_name = _icon_name
		if not icon_texture:
			if icon_name != "":
				icon_texture = load("res://Assets/Sprites/Icons/%s.png" % icon_name)
var color := Color.WHITE
var speed := 1.0
var icon_scale := Vector3.ONE
var radius := 1.0

func effect_start() -> void:
	for mi in get_tree().get_nodes_in_group("mesh"):
		mi = mi as MeshInstance3D
		mi.material_override.albedo_texture = icon_texture
		mi.material_override.albedo_color = color
		mi.scale = icon_scale
	for arm in get_tree().get_nodes_in_group("arm"):
		arm = arm as Node3D
		arm.position.x = radius
	%AnimationPlayer.speed_scale = speed
	effect_done.emit()
	
func on_effect_end() -> void:
	effect_died.emit()
	queue_free()
