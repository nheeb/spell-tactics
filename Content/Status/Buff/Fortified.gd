extends EntityStatusLogic

const VIS_FORT = preload("res://VFX/Effects/VisualFortify.tscn")

func on_birth() -> void:
	TimedEffect.new_combat_change(check_if_armor).register(combat)
	entity.cover += 2
	entity.armor += 3
	combat.animation.update_hp(entity)

func on_load() -> void:
	combat.animation.add_staying_effect(VIS_FORT, entity.visual_entity, "fort")

func on_death() -> void:
	entity.cover -= 2
	combat.animation.remove_staying_effect(entity.visual_entity, "fort")

func check_if_armor():
	if entity.armor <= 0:
		self_remove()
