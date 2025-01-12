class_name PAPass extends PlayerAction

func _init() -> void:
	action_string = "Passing"
	blocking_types = [InputUtility.InputBlockType.Any]
	changes_combat = true

func is_valid(combat: Combat) -> bool:
	return combat.current_phase == Combat.RoundPhase.Spell

func execute(combat: Combat) -> void:
	if combat.input.current_castable:
		await combat.action_stack.process_player_action(PADeselectCastable.new())
	await combat.action_stack.process_callable(
		combat.advance_and_process_until_next_player_action_needed
	)
