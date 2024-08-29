class_name EnemyActionPlan extends Resource

@export var enemy_ref: EntityReference
@export var action_args: EnemyActionArgs
@export var target_ref: UniversalReference
@export var plan_details := {}

var action: EnemyAction:
	get:
		if action_args:
			return action_args.action
		else:
			return null
var _logic: EnemyActionLogic
var score_cache := -1.0
var executed := false
var fizzled := false

#####################################################
## Constructor & Getters for real combat instances ##
#####################################################

func _init(_enemy = null, _action_args = null, _target = null, combat: Combat = null) -> void:
	if _enemy is EntityReference:
		enemy_ref = _enemy
	elif _enemy is EnemyEntity:
		enemy_ref = _enemy.get_reference()
	action_args = _action_args as EnemyActionArgs
	if _target is UniversalReference:
		target_ref = _target
	elif _target:
		if _target.has_method("get_reference"):
			target_ref = _target.get_reference()
	if combat:
		create_action_logic(combat)

func get_enemy(combat: Combat) -> EnemyEntity:
	if enemy_ref:
		return enemy_ref.resolve(combat) as EnemyEntity
	return null

func get_target(combat: Combat) -> Variant:
	if target_ref:
		return target_ref.resolve(combat)
	return null

func get_logic(combat: Combat) -> EnemyActionLogic:
	if not _logic:
		create_action_logic(combat)
	if _logic:
		return _logic
	return null

########################
## Methods for details #
########################

func get_detail(key: Variant, default: Variant = null) -> Variant:
	return Utility.dict_safe_get(plan_details, key, default)

func get_detail_and_resolve(combat: Combat, key: Variant, default: Variant = null) -> Variant:
	var value = get_detail(key, default)
	if value is UniversalReference:
		value = value.resolve(combat)
	return value

func set_detail(key: Variant, value: Variant) -> void:
	assert(not (value is Object and (not value is Resource)), "Can this be serialized?")
	plan_details[key] = value

func create_detail(key: Variant, value: Variant) -> void:
	if not key in plan_details.keys():
		if value is Object:
			if value.has_method("get_reference"):
				value = value.get_reference()
		set_detail(key, value)

#######################
## Methods for usage ##
#######################

func create_action_logic(combat: Combat) -> void:
	if get_enemy(combat) and action:
		var new_action_logic = action.logic_script.new() as EnemyActionLogic
		assert(new_action_logic, "Enemy Action Logic wasn't created.")
		new_action_logic.args = action_args
		new_action_logic.action = action
		new_action_logic.combat = combat
		new_action_logic.enemy = get_enemy(combat)
		new_action_logic.target = get_target(combat)
		new_action_logic.plan = self
		new_action_logic.setup()
		_logic = new_action_logic

## ACTION
func execute(combat: Combat):
	if has_movement():
		await combat.action_stack.process_callable(get_movement().execute.bind(combat))
	var possible_right_now := combat.action_stack.process_result(
		is_possible.bind(combat, false)
	)
	await combat.action_stack.active_ticket.wait()
	if possible_right_now.value:
		await get_logic(combat).execute()
	else:
		fizzled = true
	executed = true

## RESULT
func is_possible(combat: Combat, include_movement := true) -> bool:
	var start_from := get_enemy(combat).current_tile
	if has_movement():
		var movement_plan := get_movement()
		var after_movement := combat.action_stack.process_result(
			movement_plan.get_estimated_destination.bind(combat, start_from)
		)
		await combat.action_stack.active_ticket.wait()
		start_from = after_movement.value
	return get_logic(combat).is_possible(start_from)

## RESULT
func get_evaluation_score(combat: Combat) -> float:
	if score_cache < 0.0:
		score_cache = 0.0
		var start_from: Tile = get_enemy(combat).current_tile
		if has_movement():
			var movement_plan := get_movement()
			var movement_score := combat.action_stack.process_result(
				movement_plan.get_evaluation_score.bind(combat)
			)
			var movement_destination := combat.action_stack.process_result(
				movement_plan.get_estimated_destination.bind(combat, start_from)
			)
			await combat.action_stack.wait()
			score_cache += movement_score.value
			start_from = movement_destination.value
		var eval := get_logic(combat).evaluate(start_from)
		score_cache += eval.get_total_score(get_enemy(combat).type.behaviour)
	return score_cache

func get_evaluation_score_cached() -> float:
	assert(score_cache >= 0.0)
	return score_cache

## RESULT
func get_estimated_destination(combat: Combat, start_from: Tile = null) -> Tile:
	if start_from == null:
		start_from = get_enemy(combat).current_tile
	if has_movement():
		var movement_plan := get_movement()
		var after_movement := combat.action_stack.process_result(
			movement_plan.get_estimated_destination.bind(combat, start_from)
		)
		await combat.action_stack.active_ticket.wait()
		start_from = after_movement.value
	return get_logic(combat).estimated_destination(start_from)

func show_preview(combat: Combat, show: bool) -> void:
	get_logic(combat).show_preview(show)

func has_movement() -> bool:
	return action.movement_action_args != null

var cached_movement_plan: EnemyActionPlan = null
func get_movement() -> EnemyActionPlan:
	if cached_movement_plan:
		return cached_movement_plan
	if has_movement():
		cached_movement_plan = EnemyActionPlan.new(
			enemy_ref, action.movement_action_args, target_ref
		)
		return cached_movement_plan
	else:
		return null

func get_alternative(combat: Combat) -> EnemyActionPlan:
	return get_logic(combat).get_alternative_plan()

func get_string_action_target(combat: Combat) -> String:
	return action.pretty_name + (" -> %10s" % str(get_target(combat)) if target_ref else "") \
			+ "<%.1f>" % score_cache
