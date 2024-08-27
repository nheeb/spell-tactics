class_name EnemyActionPlan extends Resource

@export var enemy_ref: EntityReference
@export var action_args: EnemyActionArgs
@export var target_ref: UniversalReference

var action: EnemyAction:
	get:
		if action_args:
			return action_args.action
		else:
			return null

var score_cache := -1.0
var executed := false
var fizzled := false

#####################################################
## Constructor & Getters for real combat instances ##
#####################################################

func _init(_enemy = null, _action_args = null, _target = null) -> void:
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

func get_enemy(combat: Combat) -> EnemyEntity:
	if enemy_ref:
		return enemy_ref.resolve(combat) as EnemyEntity
	return null

func get_action_logic(combat: Combat) -> EnemyActionLogic:
	if get_enemy(combat) and action:
		return get_enemy(combat).get_action_logic(action_args)
	return null

func get_target(combat: Combat) -> Variant:
	if target_ref:
		return target_ref.resolve(combat)
	return null

#######################
## Methods for usage ##
#######################

## ACTION
func execute(combat: Combat):
	if has_movement():
		await combat.action_stack.process_callable(get_movement().execute.bind(combat))
	var possible_right_now := combat.action_stack.process_result(
		is_possible.bind(combat, false)
	)
	await combat.action_stack.active_ticket.wait()
	if possible_right_now.value:
		await get_action_logic(combat).execute(get_target(combat))
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
	return get_action_logic(combat).is_possible(get_target(combat), start_from)

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
		var eval := get_action_logic(combat).evaluate(get_target(combat), start_from)
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
	return get_action_logic(combat).estimated_destination(get_target(combat), start_from)

func show_preview(combat: Combat, show: bool) -> void:
	get_action_logic(combat).show_preview(get_target(combat), show)

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
	return get_action_logic(combat).get_alternative_plan(get_target(combat))

func get_string_action_target(combat: Combat) -> String:
	return action.pretty_name + (" -> %10s" % str(get_target(combat)) if target_ref else "") \
			+ "<%.1f>" % score_cache
