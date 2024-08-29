extends EnemyActionLogic

# args: EnemyActionArgs
# action: EnemyAction
# combat: Combat
# enemy: EnemyEntity
# plan: EnemyActionPlan
# target

func _execute():
	pass

func _is_possible(enemy_tile: Tile) -> bool:
	return true

#func _evaluate(enemy_tile: Tile) -> EnemyActionEval:
	#return null

#func _estimated_destination(enemy_tile: Tile) -> Tile:
	#return enemy_tile

#func _show_preview(show: bool) -> void:
	#pass

#func _get_alternative_plan() -> EnemyActionPlan:
	#return null

#func _get_target_pool() -> Array:
	#var all_targets := []
	#
	#return all_targets
