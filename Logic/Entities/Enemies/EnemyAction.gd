class_name EnemyAction extends CombatAction

## Reference to the enemy holding the EnemyAction
var enemy: EnemyEntity

## This indicates whether the Enemy can choose to select this action
@export var selectable := false

## Type of the Action
@export var type: EnemyActionType

## Custom score modification (comes from the EnemyActionTemplate)
@export var score_factor := 1.0

## If avoided the Action's score will be massively reduced which leads to it
## only being chosen as last resort.
@export var avoid := false
const AVOID_SCORE_FACTOR = 0.01

## Classic CombatLogic Object (created by CombatObjectType).
var logic: EnemyActionLogic

## This is a reference to the Actions's pre action (Movement most of the time)
## The getter & setter & export var make sure it gets serialized properly while
## maintaining easy access.
@export var pre_action_reference: CombatObjectReference
var pre_action: EnemyAction:
	set(x):
		if x is EnemyAction:
			pre_action = x
			pre_action_reference = pre_action.get_reference()
	get:
		if pre_action == null and pre_action_reference != null and combat != null:
			pre_action = pre_action_reference.resolve(combat)
		return pre_action

## Uses the combat log flavors to test if the Action is currently on cooldown.
## TODO Make this based on a cooldown property to be faster and cleaner.
func is_on_cooldown() -> bool:
	var cooldown: int = data.get("cooldown", type.cooldown) as int
	if cooldown > 0:
		# Get last usage by filtering the log with ActionFlavor
		var previous_log_entries := combat.log.filtered_entries(
			ActionFlavor.new().set_owner(enemy)
				.add_tag(ActionFlavor.Tag.EnemyActionSpecific)
				.add_data("action", type)
				.finalize(combat),
			combat.current_round - cooldown
		)
		if previous_log_entries:
			return true
	return false

## RESULT
func get_possible_plans() -> Array[EnemyActionPlan]:
	# Test if action is on cooldown
	if is_on_cooldown():
		return []
	var plans: Array[EnemyActionPlan] = []
	# NOTE EnemyActions with multiple TargetRequirements are ridicolous.
	# Especially when you consider that you still can have random tile selection
	# in the effect itself. This here is just for different eval scores and a single
	# target should be more than enough for that.
	if get_target_requirements().size() > 1:
		push_error("EnemyActions with multiple target requirements are not supported.")
		return []
	elif get_target_requirements().size() == 1:
		create_details(enemy)
		# TargetRequirement takes care of getting all the possible targets
		# as long as details are created.
		var targets := get_next_requirement().get_possible_targets(self)
		reset_details()
		for t in targets:
			plans.append(EnemyActionPlan.new(enemy, self, t))
	else:
		plans = [EnemyActionPlan.new(enemy, self)]
	# Calculate scores for the plans
	for plan in plans:
		await plan.calculate_score()
	# Cut down possible plans to target_consider_count
	if plans.size() > type.target_consider_count:
		if type.target_consider_method == EnemyActionType.TargetConsiderMethod.Best:
			Utility.array_sort(
				plans,
				func (plan: EnemyActionPlan): return plan.get_score(),
				false)
		elif type.target_consider_method == EnemyActionType.TargetConsiderMethod.Random:
			plans.shuffle()
		plans = plans.slice(0, type.target_consider_count)
	return plans
