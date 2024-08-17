extends EnemyActionLogic

func _execute(target):
	pass

func _is_possible(target) -> bool:
	return true

func _evaluate(target) -> EnemyActionEval:
	return null

func _estimated_destination(target) -> Tile:
	return null
