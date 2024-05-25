extends Control


func set_hp(hp, armor, max_hp):
	%Bar.material.set_shader_parameter("health", hp)
	%Bar.material.set_shader_parameter("max_health", max_hp)
	%Bar.material.set_shader_parameter("shield", armor)
