extends EntityStatusLogic

func on_birth() -> void:
	var flavor := ActionFlavor.new() \
		.add_tag(ActionFlavor.Tag.Damage) \
		.add_tag(ActionFlavor.Tag.Melee) \
		.set_owner(entity) \
		.finalize(combat)
	TimedEffect.new_flavor_reaction(flavor, poison_melee_effect).register(combat)

func poison_melee_effect():
	var flavor := combat.action_stack.active_ticket.get_flavor(true)
	for target in UniversalReference.dereference_array(flavor.targets, combat):
		if target is HPEntity:
			target.apply_status(Preloaded.STATUS_POISON)
	combat.action_stack.push_behind_active(self_remove)
