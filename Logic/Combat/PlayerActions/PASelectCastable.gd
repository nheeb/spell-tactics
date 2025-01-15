class_name PASelectCastable extends PlayerAction

var castable: Castable

func _init(_castable: Castable) -> void:
	castable = _castable
	action_string = "Select Castable <%s>" % castable
	blocking_types = [InputUtility.InputBlockType.Any]

func is_valid(combat: Combat) -> bool:
	return castable.is_selectable()

func execute(combat: Combat) -> void:
	if combat.input.current_castable:
		await combat.action_stack.process_player_action(
			PADeselectCastable.new().force_execution()
		)
	combat.input.select_castable(castable)
	combat.action_stack.active_ticket.finish()
	await VisualTime.new_timer(.15).timeout
	combat.action_stack.process_player_action(PAAutoLoadEnergy.new())
