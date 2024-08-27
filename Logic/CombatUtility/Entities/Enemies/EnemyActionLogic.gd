class_name EnemyActionLogic extends Object

var args: EnemyActionArgs
var action: EnemyAction
var combat: Combat
var enemy: EnemyEntity

#########################
## Methods for calling ##
#########################

func execute(target):
	await _execute(target)

func is_possible(target, enemy_tile: Tile = enemy.current_tile) -> bool:
	return _is_possible(target, enemy_tile)

func evaluate(target, enemy_tile: Tile = enemy.current_tile) -> EnemyActionEval:
	if is_possible(target, enemy_tile):
		var evaluation := _evaluate(target, enemy_tile)
		if evaluation == null:
			evaluation = EnemyActionEval.from_cv_array(action.default_scores)
		return evaluation
	else:
		return EnemyActionEval.new()

func estimated_destination(target, enemy_tile: Tile = enemy.current_tile) -> Tile:
	var destinaion := _estimated_destination(target, enemy_tile)
	if destinaion != null:
		return destinaion
	else:
		return enemy_tile

func show_preview(target, show: bool) -> void:
	_show_preview(target, show)

func get_alternative_plan(target) -> EnemyActionPlan:
	var plan := _get_alternative_plan(target)
	if plan:
		return plan
	elif action.alternative_action_args:
		return EnemyActionPlan.new(enemy, action.alternative_action_args, target)
	return null

func get_target_pool() -> Array:
	return _get_target_pool()

############################
## Methods for overriding ##
############################

func _execute(target):
	pass

func _is_possible(target, enemy_tile) -> bool:
	return true

func _evaluate(target, enemy_tile) -> EnemyActionEval:
	return null

func _estimated_destination(target, enemy_tile: Tile) -> Tile:
	return enemy_tile

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
