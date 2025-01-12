class_name PAAutoUnloadEnergy extends PlayerAction

func _init() -> void:
	action_string = "Auto Unload Energy"
	blocking_types = [InputUtility.InputBlockType.OrbTransition]

func is_valid(combat: Combat) -> bool:
	return combat.input.current_castable != null

func execute(combat: Combat) -> void:
	for socket in combat.input.current_castable.get_card().get_loaded_energy_sockets():
		await combat.action_stack.process_player_action(
			PAUnloadSocket.new(socket).force_execution()
		)
