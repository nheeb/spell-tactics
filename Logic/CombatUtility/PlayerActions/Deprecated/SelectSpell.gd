class_name SelectSpell extends PlayerAction

var selected_spell: Spell

func _init(selected: Spell) -> void:
	selected_spell = selected
	action_string = "Select spell %s" % selected
	printerr("Using deprecated PlayerAction %s" % action_string)
	
func is_valid(combat: Combat) -> bool:
	# is payable (validation, but unpayable spell should not be able to be selected in UI)
	var possible_payment: EnergyStack = combat.energy.player_energy.get_possible_payment(selected_spell.logic.get_costs()) 
	return possible_payment != null

func execute(combat: Combat) -> void:
	combat.get_phase_node(Combat.RoundPhase.Spell).select_spell(selected_spell)
