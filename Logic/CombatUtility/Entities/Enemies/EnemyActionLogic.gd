class_name EnemyActionLogic extends Object

var args: EnemyActionArgs
var action: EnemyAction
var combat: Combat
var enemy: EnemyEntity

var movement_done := false

#########################
## Methods for calling ##
#########################

func execute(target):
	if has_movement():
		get_movement_logic().execute(target)
		movement_done = true
	_execute(target)
	movement_done = false

func is_possible(target) -> bool:
	if has_movement():
		if action.movement_mandatory:
			return _is_possible(target) and get_movement_logic().is_possible(target)
	return _is_possible(target)

func evaluate(target) -> EnemyActionEval:
	if is_possible(target):
		var evaluation := _evaluate(target)
		if evaluation == null:
			evaluation = EnemyActionEval.from_cv_array(action.default_scores)
		if has_movement():
			evaluation = evaluation.add(get_movement_logic().evaluate(target))
		return evaluation
	else:
		return EnemyActionEval.new()

func estimated_destination(target) -> Tile:
	var destinaion := _estimated_destination(target)
	if destinaion != null:
		return destinaion
	return estimated_destination_after_movement(target)

func show_preview(target, show: bool) -> void:
	if has_movement():
		get_movement_logic().show_preview(target, show)
	_show_preview(target, show)

func get_alternative_plan(target) -> EnemyActionPlan:
	var plan := _get_alternative_plan(target)
	if plan:
		return plan
	elif action.alternative_action:
		return EnemyActionPlan.new(enemy, action.alternative_action, target)
	return null

func has_movement() -> bool:
	return action.movement_action != null

func get_movement_logic() -> EnemyActionLogic:
	if action.movement_action:
		return enemy.get_action_logic(action.movement_action)
	return null

func estimated_destination_after_movement(target) -> Tile:
	if has_movement():
		return get_movement_logic().estimated_destination(target)
	else:
		return enemy.current_tile

func get_target_pool() -> Array:
	return _get_target_pool()

############################
## Methods for overriding ##
############################

func _execute(target):
	pass

func _is_possible(target) -> bool:
	return true

func _evaluate(target) -> EnemyActionEval:
	return null

func _estimated_destination(target) -> Tile:
	return null

func _show_preview(target, show: bool) -> void:
	show_movement_arrow(target, show)
	show_action_icon_over_enemy(show)

func _get_alternative_plan(target) -> EnemyActionPlan:
	return null

func _get_target_pool() -> Array:
	var all_targets := []
	match action.target_type:
		EnemyAction.TargetType.None:
			return []
		EnemyAction.TargetType.Foes:
			all_targets = combat.get_all_hp_entities()
			all_targets = all_targets.filter(
				func (t):
					return t.team != enemy.team
			)
		EnemyAction.TargetType.Allies:
			all_targets = combat.get_all_hp_entities()
			all_targets = all_targets.filter(
				func (t):
					return t.team == enemy.team
			)
		EnemyAction.TargetType.Tiles:
			all_targets = combat.level.get_all_tiles()
		EnemyAction.TargetType.Entities:
			all_targets = combat.level.get_all_entities()
	return all_targets

####################
## Helper Methods ##
####################

func show_movement_arrow(target, show: bool):
	var from: Tile = enemy.current_tile
	var to: Tile = estimated_destination(target)
	if from != to:
		pass
		# TODO Nitai do this

func show_action_icon_over_enemy(show: bool):
	pass # TODO Nitai do this as well
