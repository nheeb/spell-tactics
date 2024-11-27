class_name CombatAction extends CombatObject

var details: CombatActionDetails

####################
## Change Details ##
####################

func set_details(_details):
	assert(details == null, "Use reset_details before you set them.")
	details = _details

func create_details(actor: Entity):
	assert(details == null, "Use reset_details before you create them.")
	details = CombatActionDetails.new(actor, self)

func add_target_to_details(target: Variant):
	assert(details)
	details.add_targets(target)

func remove_target_from_details(value: Variant = null):
	assert(details)
	details.remove_targets(value)

func reset_details():
	assert(details)
	details = null

func is_target_valid(target: Variant, requirement_or_index = null) -> bool:
	assert(details)
	assert(get_target_requirements())
	if requirement_or_index == null:
		requirement_or_index = 0
	if requirement_or_index is int:
		requirement_or_index = Utility.array_safe_get(
			get_target_requirements(), requirement_or_index
		)
	var req := requirement_or_index as TargetRequirement
	assert(req)
	return not req.convert_target(target).is_empty()

##########################
## Type & Logic Getters ##
##########################

func get_action_type() -> CombatActionType:
	return get_generic_type() as CombatActionType

func get_action_logic() -> CombatActionLogic:
	return get_generic_logic() as CombatActionLogic

##############################
## Wrapper for requirements ##
##############################

func get_target_requirements() -> Array[TargetRequirement]:
	if get_action_type():
		return get_action_type().target_requirements
	push_warning("CombatAction has no CombatActionType")
	return []

func are_requirements_fullfilled() -> bool:
	assert(details, "Details should exist at this point.")
	return details.are_requirements_fullfilled()

func get_unfullfilled_requirements() -> Array[TargetRequirement]:
	assert(details, "Details should exist at this point.")
	return details.get_unfullfilled_requirements()

func get_next_requirement() -> TargetRequirement:
	assert(details, "Details should exist at this point.")
	return details.get_next_requirement()
