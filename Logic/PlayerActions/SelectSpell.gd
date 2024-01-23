class_name SelectSpell extends PlayerAction

var selected_spell: Spell

func _init(selected: Spell) -> void:
	selected_spell = selected
	action_string = "Select spell %s" % selected
	
func is_valid(combat: Combat) -> bool:
	# is payable (validation, but unpayable spell should not be able to be selected in UI)
	return Utility.get_possible_payment(combat.energy.player_energy,
										  selected_spell.logic.get_costs()) is Array

func execute(combat: Combat) -> void:
	combat.get_phase_node(Combat.RoundPhase.Spell).select_spell(selected_spell)
