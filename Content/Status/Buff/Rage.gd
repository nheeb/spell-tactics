extends EntityStatusLogic

func on_birth() -> void:
	TimedEffect.new_flavor_reaction(
		ActionFlavor.new().set_owner(entity)
			.add_tag(ActionFlavor.Tag.EnemyActionGeneric)
			.finalize(combat),
		rage_effect
	).trigger_after_active_ticket().register(combat)

func rage_effect():
	combat.animation.say(entity,"RAGE!",{"color": Color.DARK_VIOLET, "font_size": 64})
	await combat.action_stack.process_callable(
		combat.enemy_phase.do_enemy_action.bind(entity as EnemyEntity)
	)
	self_remove()
