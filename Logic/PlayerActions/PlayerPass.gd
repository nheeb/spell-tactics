class_name PlayerPass extends PlayerAction

func _init() -> void:
	action_string = "Passing"

func is_valid(combat: Combat) -> bool:
	return combat.current_phase == Combat.RoundPhase.Spell or combat.current_phase == Combat.RoundPhase.Movement

func execute(combat: Combat) -> void:
	combat.advance_and_process_until_next_player_action_needed()
