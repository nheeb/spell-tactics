extends EntityStatusLogic

func on_birth() -> void:
	TimedEffect.new_combat_change(check_if_armor).register(combat)
	entity.cover += 1
	entity.armor += 3
	combat.animation.update_hp(entity)

func on_load() -> void:
	pass

func check_if_armor():
	if entity.armor <= 0:
		self_remove()
