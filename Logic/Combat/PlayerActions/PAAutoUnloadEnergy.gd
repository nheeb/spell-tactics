class_name PAAutoUnloadEnergy extends PlayerAction

func _init() -> void:
	action_string = "Auto Unload Energy"

func is_valid(combat: Combat) -> bool:
	return combat.input.current_castable != null \
			and combat.input.current_castable.get_type() is SpellType

func execute(combat: Combat) -> void:
	var sockets := combat.input.current_castable.get_card().get_loaded_energy_sockets()
	var actions : Array[PlayerAction] = []
	actions.append(PABlockInput.new(true))
	actions.append_array(sockets.map(func(s): return PAUnloadSocket.new(s)))
	actions.append(PABlockInput.new(false))
	
	for action in actions:
		await combat.action_stack.process_player_action(action, true)

func on_fail(combat: Combat) -> void:
	pass
