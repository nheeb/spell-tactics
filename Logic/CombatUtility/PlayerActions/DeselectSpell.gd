class_name DeselectSpell extends PlayerAction

func _init() -> void:
	action_string = "Deselect spell"
	
func is_valid(combat: Combat) -> bool:
	return true

func execute(combat: Combat) -> void:
	combat.get_phase_node(Combat.RoundPhase.Spell).deselect_spell()
