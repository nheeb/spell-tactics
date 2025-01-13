class_name EnemyEntity extends Entity

var agility: int
var strength: int
var movement_range: int

#var action_logic := {} # EnemyActionTemplate -> EnemyActionLogic
var action_plan: EnemyActionPlan

##################################
## Methods for the action stack ##
##################################

## ACTION
func plan_next_action():
	if not action_plan:
		action_plan = await get_random_action_plan()
	else:
		var possible: bool = await combat.action_stack.get_result(
			action_plan.is_possible.bind(combat)
		)
		if (not possible) or action_plan.action_args.try_to_avoid:
			var new_action_plan: EnemyActionPlan = await get_random_action_plan()
			if not new_action_plan.action_args.try_to_avoid:
				action_plan = new_action_plan

## ACTION
func do_action():
	while true:
		# If no plan, make one
		if not action_plan:
			await combat.action_stack.process_callable(plan_next_action)
			continue
		
		# Check if possible
		var possible = combat.action_stack.process_result(
			action_plan.is_possible.bind(combat)
		)
		await combat.action_stack.wait()
		
		# Get alternative if not possible
		if not possible.value:
			action_plan = action_plan.get_alternative(combat)
			continue
		
		# Execute
		combat.action_stack.preset_flavor(
			ActionFlavor.new().set_owner(self)
				.add_tag(ActionFlavor.Tag.EnemyActionSpecific)
				.add_target(action_plan.target_ref)
				.add_data("action", action_plan.action)
				.add_data("action_name", action_plan.action.internal_name)
				.finalize(combat)
		)
		await combat.action_stack.process_callable(
			action_plan.execute.bind(combat)
		)
		action_plan = null
		break

######################
## Internal Methods ##
######################

func get_action_pool() -> Array[EnemyActionTemplate]:
	var actions : Array[EnemyActionTemplate] = []
	actions.append_array(type.actions)
	for se in status_array:
		actions.append_array(se.get_enemy_actions())
	actions.append_array(combat.global_enemy_actions)
	return actions

## RESULT
func get_random_action_plan() -> EnemyActionPlan:
	var d_power : float = get_bahviour().decision_power
	var plans: Array[EnemyActionPlan] = []
	for action_args in get_action_pool():
		var plans_result := combat.action_stack.process_result(
			action_args.get_possible_plans.bind(self)
		)
		await combat.action_stack.wait()
		plans.append_array(plans_result.value)
	var scores := plans.map(
		func(plan: EnemyActionPlan):
			return pow(plan.get_evaluation_score_cached(), d_power)
	)
	var names_for_log := plans.map(
		func (plan: EnemyActionPlan):
			return plan.get_string_action_target(combat)
	)
	var title_for_log := str(self) + " chooses an action:"
	var index := Utility.random_index_of_scores(scores, true, names_for_log, title_for_log)
	combat.log.add(Utility.random_index_of_scores_report)
	assert(index != -1, "No enemy action was chosen. There should always be a backup action")
	return plans[index]

######################
## Entity Overrides ##
######################

func on_birth():
	await super()
	# TBD Removed this for now.
	#TimedEffect.new_combat_change(plan_next_action) \
		#.set_id("_cc_plan_action").set_solo().register(combat)

func on_death():
	super()
	combat.enemies.erase(self)
	if get_enemy_type().gain_drain_on_kill:
		combat.castables.get_active_from_name("Drain").add_to_bonus_uses(1)

func get_enemy_type() -> EnemyEntityType:
	return type as EnemyEntityType 

const DEFAULT_BEHAVIOUR = preload("res://Content/Enemies/Behaviours/EnemyBehaviourDefault.tres")
func get_bahviour() -> EnemyBehaviour:
	if get_enemy_type().behaviour:
		return get_enemy_type().behaviour
	return DEFAULT_BEHAVIOUR

## ACTION
func on_hover_long(h: bool) -> void:
	await super(h)
	if action_plan and Game.DEBUG_OVERLAY:
		await action_plan.show_preview(combat, h)
