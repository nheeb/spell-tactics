class_name PAActivateCastable extends PlayerAction

var clicked_on_card := false

func _init(_clicked_on_card: bool = true) -> void:
	clicked_on_card = _clicked_on_card
	action_string = "Activate Castable"

func is_valid(combat: Combat) -> bool:
	if combat.input.current_castable:
		if combat.input.current_castable.is_castable():
			return true
	return false

func execute(combat: Combat) -> void:
	combat.animation.callable(
		combat.input.current_castable.update_current_state.bind(true)
	)
	if clicked_on_card:
		combat.animation.callable(combat.input.current_castable.get_card() \
						.warp.bind(Events.cards3d_ray_collision_point)) \
						.set_duration(.3)
	else:
		# TODO check how these situations can even occur
		if combat.input.current_castable == null:
			push_error("ActivateCastable executed without a current_castable")
			return
		# this happened with the "throw card" active
		if combat.input.current_castable.get_card() == null:
			push_error("ActivateCastable executed but current_castable has no card.")
			return
		combat.animation.callable(combat.input.current_castable.get_card().warp) \
						.set_duration(.2)
	combat.animation.wait(.3)
	await combat.input.current_castable.get_logic().set_preview_visuals(false)
	combat.action_stack.preset_combat_change()
	var flavor := ActionFlavor.new().set_owner(combat.player).add_tag(ActionFlavor.Tag.Cast)
	if combat.input.current_castable is Spell:
		flavor.add_tag(ActionFlavor.Tag.Spell)
	else:
		flavor.add_tag(ActionFlavor.Tag.Active)
	combat.action_stack.preset_flavor(
		flavor.finalize(combat)
	)
	await combat.action_stack.process_callable(combat.input.current_castable.cast)

func on_fail(combat: Combat) -> void:
	pass
