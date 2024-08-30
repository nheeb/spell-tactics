class_name PAPass extends PlayerAction

func _init() -> void:
	action_string = "Passing"

func is_valid(combat: Combat) -> bool:
	return combat.current_phase == Combat.RoundPhase.Spell

func execute(combat: Combat) -> void:
	await combat.action_stack.active_ticket.finish()
	if combat.input.current_castable:
		combat.input.process_action(PADeselectCastable.new())
		await Game.get_tree().process_frame
	combat.action_stack.process_callable(
		combat.advance_and_process_until_next_player_action_needed
	)
