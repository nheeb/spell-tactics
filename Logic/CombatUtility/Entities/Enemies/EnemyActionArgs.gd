class_name EnemyActionArgs extends Resource

## Wraps an enemy action together with optional custom arguments.

@export var action: EnemyAction:
	set(a):
		action = a
		if a:
			a._on_load()

@export_group("Arguments")
@export var args := []
@export var kwargs := {}

func _init(_action: EnemyAction = null, _args := [], _kwargs := {}) -> void:
	action = _action
	args = _args
	kwargs = _kwargs

func get_arg(index: int, default = null) -> Variant:
	default = Utility.array_safe_get(action.default_args, index, false, default)
	return Utility.array_safe_get(args, index, false, default)

func get_kwarg(key: Variant, default = null) -> Variant:
	default = Utility.dict_safe_get(action.default_kwargs, key, default)
	return Utility.dict_safe_get(kwargs, key, default)

## RESULT
func get_possible_plans(enemy: EnemyEntity) -> Array[EnemyActionPlan]:
	var combat := enemy.combat
	var all_targets := enemy.get_action_logic(self).get_target_pool()

	# Testing if in Range and action is_possible(target)
	var suitable_targets := []
	var enemy_tile = enemy.current_tile
	for target in all_targets:
		var target_tile: Tile
		if target is Tile:
			target_tile = target
		elif target is Entity:
			target_tile = target.current_tile
		if target_tile:
			if action.target_range_looking != -1:
				if enemy_tile.distance_to(target_tile) > action.target_range_looking:
					continue
			if action.target_range_walking != -1:
				if combat.level.get_shortest_distance(enemy_tile, target_tile) \
					> action.target_range_walking:
						continue
	
	# Making Plans
	var plans : Array[EnemyActionPlan] = []
	for suitable_target in suitable_targets:
		plans.append(EnemyActionPlan.new(enemy, self, suitable_target))
	
	# Evaluate if possible
	var possible_dict := {}
	for plan in plans:
		possible_dict[plan] = combat.action_stack.process_result(
			plan.is_possible.bind(combat)
		)
	await combat.action_stack.wait()
	plans.filter(
		func (p):
			return possible_dict[p].value
	)
	
	# First score calculation
	var score_dict := {}
	for plan in plans:
		score_dict[plan] = combat.action_stack.process_result(
			plan.get_evaluation_score.bind(combat)
		)
	await combat.action_stack.wait()
	
	if action.target_consider_method == EnemyAction.TargetConsiderMethod.Best:
		plans.sort_custom(
			func (a, b):
				return score_dict[a].value > score_dict[b].value
		)
		plans = plans.slice(0, action.target_consider_count)
	
	return plans
