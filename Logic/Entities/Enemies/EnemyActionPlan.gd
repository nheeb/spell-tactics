class_name EnemyActionPlan extends CombatActionDetails

var score_cache := -1.0
var executed := false

#######################
## Methods for usage ##
#######################

## ACTION
func calculate_score() -> void:
	pass

func get_score() -> float:
	if score_cache == -1.0:
		push_warning("Seems like the score for this EnemyActionPlan wasn't calculated.")
		return 0.0
	return score_cache

func get_string_action_target_score() -> String:
	var action_name := combat_action.get_action_type().pretty_name
	var target_name := ""
	var first_target = Utility.array_safe_get(get_target_array(0), 0)
	if first_target:
		target_name = " -> %10s" % str(first_target)
	return action_name + target_name + " <%.1f>" % score_cache

### ACTION
#func execute(combat: Combat):
	#if has_movement():
		#await combat.action_stack.process_callable(get_movement().execute.bind(combat))
	#var possible_right_now := combat.action_stack.process_result(
		#is_possible.bind(combat, false)
	#)
	#await combat.action_stack.active_ticket.wait()
	#if possible_right_now.value:
		#await get_logic().execute()
	#else:
		#fizzled = true
	#executed = true

### RESULT
#func is_possible(combat: Combat, include_movement := true) -> bool:
	#if not get_logic():
		#await combat.action_stack.process_callable(create_action_logic.bind(combat))
	#var start_from := get_enemy(combat).current_tile
	#if has_movement() and include_movement:
		#var movement_plan := get_movement()
		#var after_movement := combat.action_stack.process_result(
			#movement_plan.get_estimated_destination.bind(combat, start_from)
		#)
		#await combat.action_stack.wait()
		#start_from = after_movement.value
	#return await get_logic().is_possible(start_from)
#
### RESULT
#func get_evaluation_score(combat: Combat) -> float:
	#if not get_logic():
		#await combat.action_stack.process_callable(create_action_logic.bind(combat))
	#if score_cache < 0.0:
		#score_cache = 0.0
		#var start_from: Tile = get_enemy(combat).current_tile
		#if has_movement():
			#var movement_plan := get_movement()
			#var movement_score := combat.action_stack.process_result(
				#movement_plan.get_evaluation_score.bind(combat)
			#)
			#var movement_destination := combat.action_stack.process_result(
				#movement_plan.get_estimated_destination.bind(combat, start_from)
			#)
			#await combat.action_stack.wait()
			#score_cache += movement_score.value
			#start_from = movement_destination.value
		#var eval := await get_logic().evaluate(start_from)
		#score_cache += eval.get_total_score(get_enemy(combat).get_bahviour())
		#score_cache *= action_args.score_factor
		#if action_args.avoid:
			#score_cache *= action_args.avoid_score_factor
	#return score_cache

### RESULT
#func get_estimated_destination(combat: Combat, start_from: Tile = null) -> Tile:
	#if not get_logic():
		#await combat.action_stack.process_callable(create_action_logic.bind(combat))
	#if start_from == null:
		#start_from = get_enemy(combat).current_tile
	#if has_movement():
		#var movement_plan := get_movement()
		#var after_movement := combat.action_stack.process_result(
			#movement_plan.get_estimated_destination.bind(combat, start_from)
		#)
		#await combat.action_stack.active_ticket.wait()
		#start_from = after_movement.value
	#return await get_logic().estimated_destination(start_from)
