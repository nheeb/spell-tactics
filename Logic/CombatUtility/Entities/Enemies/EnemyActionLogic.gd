class_name EnemyActionLogic extends Object

var action: EnemyAction
var combat: Combat
var enemy: EnemyEntity

#########################
## Methods for calling ##
#########################

func execute(target):
	_execute(target)

func is_possible(target) -> bool:
	return _is_possible(target)

func evaluate(target) -> EnemyActionEval:
	if is_possible(target):
		var evaluation := _evaluate(target)
		if evaluation == null:
			evaluation = EnemyActionEval.from_cv_array(action.default_scores)
		return evaluation
	else:
		return EnemyActionEval.new()

func estimated_destination(target) -> Tile:
	return _estimated_destination(target)

func show_preview(target, show: bool) -> void:
	_show_preview(target, show)

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
