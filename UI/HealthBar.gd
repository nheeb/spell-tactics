extends Node3D

@onready var bar = $SubViewport/HealthBar2D.get_node("%Bar")

@export var hp: int = 0
@export var max_hp: int = 0
@export var shield: int = 0

func _enter_tree() -> void:
	$HealthbarQuad.get_active_material(0).albedo_color = Color.WHITE 	# was transparent for editor beauty ;)
	$HealthbarQuad.get_active_material(0).albedo_texture = $SubViewport.get_texture()
	
	
func update_hp(hp_new, max_hp_new, shield_new):
	#print("UPDATE HP ", hp_new)
	# determine whether any animation should play, these are responsible for affecting
	# the shader parameters
	if max_hp == max_hp_new:
		if hp_new < hp or shield_new < shield:
			# got dealt damage
			var total_difference = max(shield - shield_new, 0) + max(hp - hp_new, 0)
			damage_by(total_difference)
		if hp_new > hp:
			# got healed
			heal_by(hp_new - hp)
		if shield_new > shield:
			# got shielded
			shield_by(shield_new - shield)
	else:
		# (re-)initialize everything, play no animation
		#print("re-init, hp = ", hp_new, " / ", max_hp_new)
		bar.material.set_shader_parameter("health", hp_new)
		bar.material.set_shader_parameter("shield", shield_new)
		bar.material.set_shader_parameter("max_health", max_hp_new)
		bar.material.set_shader_parameter("highlight_damage", 0.0)
		pass
	
	# apply logical state
	self.hp = hp_new
	self.max_hp = max_hp_new
	self.shield = shield_new




const HIT_DURATION = 0.6
func damage_by(damage: int):
	var target_health = float(hp) - float(damage)
	print("shader health before ", bar.material.get("shader_parameter/health"))


	var tween = VisualTime.new_tween()
	if damage <= shield:
		# just shield highlighting
		pass
	elif shield > 0:
		# mixed highlighting
		# TODO first remove the shield then the real health
		pass
	else:
		# just health highlighting
		bar.material.set("shader_parameter/target_health", target_health)
		tween.tween_method(func(x): bar.material.set("shader_parameter/health", x), float(hp), target_health, HIT_DURATION)
		tween.parallel().tween_method(func(x): bar.material.set("shader_parameter/highlight_progress", x), 0.0, 1.0, HIT_DURATION/3.0)
		tween.tween_method(func(x): bar.material.set("shader_parameter/highlight_progress", x), 1.0, 0.0, 2.0 * HIT_DURATION/3.0)
	
	await tween.finished

	bar.material.set("shader_parameter/highlight_damage", 0.0)
	

func shield_by(by: int):
	print("shield by ", by)
	bar.material.set_shader_parameter("shield", by)
	
func heal_by(heal: int):
	print("heal by ", heal)
	var old_hp = bar.material.get_shader_parameter("health")
	bar.material.set_shader_parameter("health", old_hp + heal)
