class_name PAPass extends PlayerAction

func _init() -> void:
	action_string = "Passing"
	printerr("Using deprecated PlayerAction %s" % action_string)

func is_valid(combat: Combat) -> bool:
	return combat.current_phase == Combat.RoundPhase.Spell

func execute(combat: Combat) -> void:
	combat.advance_and_process_until_next_player_action_needed()
