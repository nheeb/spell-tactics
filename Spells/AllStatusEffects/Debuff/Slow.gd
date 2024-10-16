extends EntityStatusLogic

func _setup_logic() -> void:
	var flavor := ActionFlavor.new() \
		.add_tag(ActionFlavor.Tag.Movement) \
		.set_owner(entity).finalize(combat)
	TimedEffect.new_discussion_entry(flavor, slow_effect).register(combat)

func slow_effect(discussion: Discussion):
	discussion.value = min(1, discussion.value)
