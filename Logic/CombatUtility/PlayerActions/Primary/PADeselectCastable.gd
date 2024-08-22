class_name PADeselectCastable extends PlayerAction

func _init() -> void:
	action_string = "Deselect Castable"

func is_valid(combat: Combat) -> bool:
	return combat.input.current_castable != null

func execute(combat: Combat) -> void:
	var unload := PAAutoUnloadEnergy.new()
	Sx.merge([
		Sx.from(unload.executed),
		Sx.from(unload.failed)
	]).subscribe(combat.input.deselect_castable, CONNECT_ONE_SHOT)
	combat.action_stack.process_player_action(unload, true)

func on_fail(combat: Combat) -> void:
	pass

