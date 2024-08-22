class_name PAAutoLoadEnergy extends PlayerAction

func _init() -> void:
	action_string = "Auto Load Energy"

func is_valid(combat: Combat) -> bool:
	return combat.input.current_castable != null \
			and combat.input.current_castable.get_type() is SpellType

func execute(combat: Combat) -> void:
	var available_orbs := combat.ui.cards3d.energy_ui.get_orbs()
	var spell := combat.input.current_castable as Spell
	var payment := combat.energy.player_energy.get_possible_payment(spell.get_costs())
	var actions : Array[PlayerAction] = []
	
	actions.append(PABlockInput.new(true))
	for energy in payment.stack:
		for orb in available_orbs:
			if orb.type == energy:
				actions.append(PALoadEnergy.new(orb))
				available_orbs.erase(orb)
				break
	actions.append(PABlockInput.new(false))
	
	for action in actions:
		combat.action_stack.process_player_action(action)

func on_fail(combat: Combat) -> void:
	pass

