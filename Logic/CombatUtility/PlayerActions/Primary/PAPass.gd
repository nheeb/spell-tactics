class_name PAPass extends PlayerAction

func _init() -> void:
	action_string = "Passing"
	push_error("Using deprecated PlayerAction %s" % action_string)

func is_valid(combat: Combat) -> bool:
	return combat.current_phase == Combat.RoundPhase.Spell

func execute(combat: Combat) -> void:
	await combat.action_stack.active_ticket.finish()
	combat.action_stack.process_callable(
		combat.advance_and_process_until_next_player_action_needed
	)
