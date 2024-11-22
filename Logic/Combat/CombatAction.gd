class_name CombatAction extends CombatObject

var details: CombatActionDetails

func set_details(_details):
	assert(details == null)
	details = _details

func reset_details():
	assert(details)
	details = null

func get_action_type() -> CombatActionType:
	return get_generic_type() as CombatActionType

func get_target_requirements() -> Array[TargetRequirement]:
	if get_action_type():
		return get_action_type().target_requirements
	push_warning("CombatAction has no CombatActionType")
	return []
