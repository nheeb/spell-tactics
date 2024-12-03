extends EntityStatusLogic

func on_birth() -> void:
	TimedEffect.new_end_phase_trigger_from_callable(poison_damage).register(combat)

func poison_damage() -> void:
	var damage := data.get_or_add("damage", 1) as int
	if entity is Entity:
		entity.inflict_damage_with_visuals(damage)
		combat.animation.say(entity, "Poison Damage")
