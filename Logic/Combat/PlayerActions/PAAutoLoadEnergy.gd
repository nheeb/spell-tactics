class_name PAAutoLoadEnergy extends PlayerAction

func _init() -> void:
	action_string = "Auto Load Energy"
	blocking_types = [InputUtility.InputBlockType.OrbTransition]

func is_valid(combat: Combat) -> bool:
	return combat.input.current_castable != null

func execute(combat: Combat) -> void:
	var available_orbs := combat.ui.cards3d.energy_ui.get_orbs()
	var castable := combat.input.current_castable
	var payment := combat.energy.player_energy.get_forced_payment(castable.get_costs())
	var actions : Array[PlayerAction] = []
	
	for energy in payment.stack:
		for orb in available_orbs:
			if orb.type == energy:
				actions.append(PALoadEnergy.new(orb))
				break

	for action in actions:
		await combat.action_stack.process_player_action(action.force_execution())
