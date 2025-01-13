class_name PADeselectCastable extends PlayerAction

func _init() -> void:
	action_string = "Deselect Castable"
	blocking_types = [InputUtility.InputBlockType.Any]

func is_valid(combat: Combat) -> bool:
	return combat.input.current_castable != null

func execute(combat: Combat) -> void:
	await combat.input.current_castable.get_logic().set_preview_visuals(false)
	#var unload := PAAutoUnloadEnergy.new()
	#Sx.merge([
		#Sx.from(unload.executed),
		#Sx.from(unload.failed)
	#]).subscribe(combat.input.deselect_castable, CONNECT_ONE_SHOT)
	await combat.action_stack.process_player_action(PAAutoUnloadEnergy.new())
	combat.input.deselect_castable()
