class_name EnemyAction extends CombatAction

@export var type: EnemyActionType
var logic: EnemyActionLogic

## RESULT
func get_possible_plans(enemy: EnemyEntity) -> Array[EnemyActionPlan]:
	var combat := enemy.combat
	# Test if same action was done before and is on cooldown
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
			return []

	# Getting all the suitable targets
	var temp_logic := get_temp_logic(enemy, combat)
	var all_targets := temp_logic.get_target_pool()
	
	# Testing if self target
	if enemy in all_targets:
		if not action.can_self_target:
			all_targets.erase(enemy)

	# Testing if in Range
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
		suitable_targets.append(target)
	
	# Making Plans
	var plans : Array[EnemyActionPlan] = []
	# Only take fixed ones if there are any
	if fixed_targets:
		for fixed_target in fixed_targets:
			plans.append(EnemyActionPlan.new(enemy, self, fixed_target, combat))
	# suitable targets otherwise
	else:
		for suitable_target in suitable_targets:
			plans.append(EnemyActionPlan.new(enemy, self, suitable_target, combat))
	
	# Evaluate if possible
	var possible_dict := {}
	for plan in plans:
		possible_dict[plan] = combat.action_stack.process_result(
			plan.is_possible.bind(combat)
		)
	await combat.action_stack.wait()
	plans = plans.filter(
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
	
	# Reduce the targets and only consider the important ones
	if action.target_consider_method == EnemyActionType.TargetConsiderMethod.Best:
		plans.sort_custom(
			func (a, b):
				return score_dict[a].value > score_dict[b].value
		)
		plans = plans.slice(0, action.target_consider_count)
	
	return plans
