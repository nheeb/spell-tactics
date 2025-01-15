class_name EnemyEntity extends Entity
## An EnemyEntity is an Entity that will do EnemyActions during the EnemyPhase

var agility: int
var strength: int
var movement_range: int

## This are the details for the Action the Enemy wants to do next.
## Since this should be made directly before the execution there is no real reason
## to have it be a member var. But we'll keep it that way for tradition reasons.
var action_plan: EnemyActionPlan

## EnemyActions are created at birth based on all the types + global templates
var action_pool: Array[EnemyAction] # TODO Serialize this

###################
## Enemy Actions ##
###################

## ACTION
func build_action_pool():
	assert(action_pool.is_empty())
	var templates: Array[EnemyActionTemplate] = []
	templates.append_array(get_enemy_type().actions)
	templates.append_array(combat.global_enemy_action_templates)
	for template in templates:
		add_actions_from_template(template)
		await combat.action_stack.wait()

func add_actions_from_template(template: EnemyActionTemplate):
	var actions := template.create_enemy_actions(combat)
	for action in actions:
		action.enemy = self
		action_pool.append(action)

## ACTION
func plan_next_action():
	if action_plan:
		push_warning("There already is an EnemyActionPlan. A new one will be planned.")
	action_plan = await get_random_action_plan()

## RESULT
func get_random_action_plan() -> EnemyActionPlan:
	var d_power : float = get_bahviour().decision_power
	var plans: Array[EnemyActionPlan] = []
	for action in action_pool:
		if not action.selectable:
			continue
		var plans_result := combat.action_stack.process_result(
			action.get_possible_plans.bind(self)
		)
		await combat.action_stack.wait()
		plans.append_array(plans_result.value)
	var scores := plans.map(
		func(plan: EnemyActionPlan):
			return pow(plan.get_score(), d_power)
	)
	var names_for_log := plans.map(
		func (plan: EnemyActionPlan):
			return plan.get_string_action_target_score()
	)
	var title_for_log := str(self) + " chooses an action:"
	var index := Utility.random_index_of_scores(scores, true, names_for_log, title_for_log)
	combat.log.add(Utility.random_index_of_scores_report)
	assert(index != -1, "No enemy action was chosen. There should always be a backup action")
	return Utility.array_safe_get(plans, index)

## ACTION
func do_action():
	# If no plan, make one
	if not action_plan:
		await combat.action_stack.process_callable(plan_next_action)
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

######################
## Entity Overrides ##
######################

## Write the entity into an EntityState (Resource)
## We don't use regular CombatObjectState for this because Entity owns Status which
## get saved inside the EntityState
func serialize() -> EntityState:
	var state: EntityState = EntityState.new(self)
	return state

func on_birth():
	await super()
	await build_action_pool()

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
