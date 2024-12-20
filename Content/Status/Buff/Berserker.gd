extends EntityStatusLogic

func on_birth() -> void:
	var flavor := ActionFlavor.new() \
		.add_tag(ActionFlavor.Tag.Damage) \
		.add_tag(ActionFlavor.Tag.Melee) \
		.set_owner(entity) \
		.finalize(combat)
	TimedEffect.new_discussion_entry(flavor, berserker_effect).register(combat)

func berserker_effect(discussion: Discussion):
	combat.action_stack.push_behind_active(self_remove)
	discussion.value += status.data.get("damage_bonus", 2)
