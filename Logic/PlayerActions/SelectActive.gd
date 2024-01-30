class_name SelectActive extends PlayerAction

var selected_active: Active

func _init(selected: Active) -> void:
	selected_active = selected
	action_string = "Select spell %s" % selected
	
func is_valid(combat: Combat) -> bool:
	# is payable (validation, but unpayable spell should not be able to be selected in UI)
	return true

func execute(combat: Combat) -> void:
	combat.get_phase_node(combat.current_phase).select_spell(selected_active)
