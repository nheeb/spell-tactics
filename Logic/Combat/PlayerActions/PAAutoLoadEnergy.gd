class_name PAAutoLoadEnergy extends PlayerAction

func _init() -> void:
	action_string = "Auto Load Energy"

func is_valid(combat: Combat) -> bool:
	return combat.input.current_castable != null \
			and combat.input.current_castable.get_type() is SpellType

func execute(combat: Combat) -> void:
	var available_orbs := combat.ui.cards3d.energy_ui.get_orbs()
	var spell := combat.input.current_castable as Spell
	var payment := combat.energy.player_energy.get_forced_payment(spell.get_costs())
	var actions : Array[PlayerAction] = []
	
	actions.append(PABlockInput.new(InputUtility.InputBlockType.OrbTransition, true))
	for energy in payment.stack:
		for orb in available_orbs:
			if orb.type == energy:
				actions.append(PALoadEnergy.new(orb))
				break
	actions.append(PABlockInput.new(InputUtility.InputBlockType.OrbTransition, false))
	
	await combat.action_stack.wait()
	
	for action in actions:
		await combat.action_stack.process_player_action(action, true)

func on_fail(combat: Combat) -> void:
	pass
