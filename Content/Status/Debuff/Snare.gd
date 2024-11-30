extends EntityStatusLogic

func on_birth() -> void:
	var flavor := ActionFlavor.new() \
		.add_tag(ActionFlavor.Tag.Movement) \
		.set_owner(entity).finalize(combat)
	TimedEffect.new_discussion_entry(flavor, snare_effect).register(combat)

func snare_effect(discussion: Discussion):
	discussion.value = 0
