class_name EnemyEntity extends HPEntity

var agility: int = 0
var strength: int = 1
var accuracy: int = 0
var resistance: int = 0
var movement_range: int = 2

var action_logic := {} # EnemyActionArgs -> EnemyActionLogic
var action_plan: EnemyActionPlan

##################################
## Methods for the action stack ##
##################################

## ACTION
func plan_next_action():
	action_plan = await get_random_action_plan()

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
		await combat.action_stack.active_ticket.wait()
		
		# Get alternative if not possible
		if not possible.value:
			action_plan = action_plan.get_alternative(combat)
			continue
		
		# Execute
		combat.action_stack.push_behind_active(
			action_plan.execute.bind(combat)
		)
		action_plan = null
		break

######################
## Internal Methods ##
######################

func get_action_pool() -> Array[EnemyActionArgs]:
	var actions : Array[EnemyActionArgs] = []
	actions.append_array(type.actions)
	for se in status_effects:
		actions.append_array(se.get_enemy_actions())
	actions.append_array(combat.global_enemy_actions)
	return actions

#func create_action_logic(action_args: EnemyActionArgs) -> EnemyActionLogic:
	#var action: EnemyAction = action_args.action
	#var new_action_logic = action.logic_script.new() as EnemyActionLogic
	#assert(new_action_logic, "Enemy Action Logic wasn't created.")
	#new_action_logic.args = action_args
	#new_action_logic.action = action
	#new_action_logic.combat = combat
	#new_action_logic.enemy = self
	#new_action_logic.setup()
	#action_logic[action_args] = new_action_logic
	#return new_action_logic
#
#func get_action_logic(action_args: EnemyActionArgs) -> EnemyActionLogic:
	#return Utility.dict_safe_get(action_logic, action_args, \
		#create_action_logic(action_args))

func get_random_action_plan() -> EnemyActionPlan:
	var d_power : float = get_enemy_type().behaviour.decision_power
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
	var title_for_log := get_name() + " chooses an action:"
	var index := Utility.random_index_of_scores(scores, true, names_for_log, title_for_log)
	combat.log.add(Utility.random_index_of_scores_report)
	return plans[index]

######################
## Entity Overrides ##
######################

func on_create() -> void:
	super.on_create()
	type = type as EnemyEntityType

func on_death():
	super.on_death()
	combat.enemies.erase(self)

func sync_with_type() -> void:
	super()
	agility = type.agility
	strength = type.strength
	accuracy = type.accuracy
	resistance = type.resistance

func get_name() -> String:
	return "%s_%s" % [type.pretty_name, id.to_string()]

func get_enemy_type() -> EnemyEntityType:
	return type as EnemyEntityType 
