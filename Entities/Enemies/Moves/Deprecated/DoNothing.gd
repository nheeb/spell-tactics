extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	match enemy.type.behaviour:
		EnemyEntityType.Behaviour.Fighter:
			return 0.0
	return 0.0

## Executes the move
func execute() -> void:
	pass

