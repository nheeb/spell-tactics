class_name PAPass extends PlayerAction

func _init() -> void:
	action_string = "Passing"

func is_valid(combat: Combat) -> bool:
	return combat.current_phase == Combat.RoundPhase.Spell

func execute(combat: Combat) -> void:
	print("A")
	await combat.action_stack.active_ticket.finish()
	print("B")
	combat.action_stack.process_callable(
		combat.advance_and_process_until_next_player_action_needed
	)
