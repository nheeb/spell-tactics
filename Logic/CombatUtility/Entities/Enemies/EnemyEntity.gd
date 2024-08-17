class_name EnemyEntity extends HPEntity

var agility: int = 0
var strength: int = 1
var accuracy: int = 0
var resistance: int = 0
var movement_range: int = 2

var action_logic := {} # EnemyAction -> EnemyActionLogic
var action_plan: EnemyActionPlan

func get_action_pool() -> Array[EnemyAction]:
	var actions : Array[EnemyAction] = []
	actions.append_array(type.actions)
	for se in status_effects:
		actions.append_array(se.get_enemy_actions())
	actions.append_array(combat.global_enemy_actions)
	return actions

func create_action_logic(action: EnemyAction) -> EnemyActionLogic:
	var logic = action.logic_script.new() as EnemyActionLogic
	assert(logic, "Enemy Action Logic wasn't created.")
	logic.action = action
	logic.combat = combat
	logic.enemy = self
	action_logic[action] = logic
	return logic

func get_action_logic(action: EnemyAction) -> EnemyActionLogic:
	return Utility.dict_safe_get(action_logic, action, create_action_logic(action))

func plan_next_action():
	action_plan = get_random_action_plan()

func get_random_action_plan() -> EnemyActionPlan:
	var d_power : float = get_enemy_type().behaviour.decision_power
	var plans: Array[EnemyActionPlan] = []
	for action in get_action_pool():
		plans.append_array(action.get_possible_plans(self))
	var scores := plans.map(
		func(plan: EnemyActionPlan):
			return pow(plan.get_evaluation_score(combat), d_power)
	)
	var names_for_log := plans.map(
		func (plan: EnemyActionPlan):
			return plan.get_string_action_target(combat)
	)
	var title_for_log := get_name() + " chooses an action:"
	var index := Utility.random_index_of_scores(scores, true, names_for_log, title_for_log)
	combat.log.add(Utility.random_index_of_scores_report)
	return plans[index]

func do_action():
	if action_plan:
		if not action_plan.is_possible(combat):
			var alternative_plan = action_plan.get_alternative(combat)
			action_plan = null
			if alternative_plan:
				if alternative_plan.is_possible(combat):
					action_plan = alternative_plan
	if not action_plan:
		plan_next_action()
	action_plan.execute(combat)
	action_plan = null

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
