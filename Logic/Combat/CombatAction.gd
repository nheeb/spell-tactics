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
	pass

func reset_details():
	assert(details)
	details = null

##########################
## Type & Logic Getters ##
##########################

func get_action_type() -> CombatActionType:
	return get_generic_type() as CombatActionType

func get_action_logic() -> CombatActionLogic:
	return get_generic_logic() as CombatActionLogic

############################
## Deal with requirements ##
############################

func get_target_requirements() -> Array[TargetRequirement]:
	if get_action_type():
		return get_action_type().target_requirements
	push_warning("CombatAction has no CombatActionType")
	return []

func are_requirements_fullfilled() -> bool:
	assert(details, "Details should exist at this point.")
	return details.are_requirements_fullfilled()

func get_next_requirement() -> TargetRequirement:
	return 
