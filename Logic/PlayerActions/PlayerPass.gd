class_name PlayerPass extends PlayerAction

func is_valid() -> bool:
	return Game.combat.current_phase == Combat.RoundPhase.Spell or Game.combat.current_phase == Combat.RoundPhase.Movement

func execute() -> void:
	Game.combat.advance_and_process_until_next_player_action_needed()
