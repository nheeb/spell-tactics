extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	return 1.0

## Executes the move
func execute() -> void:
	combat.movement.move_entity(enemy, combat.level.get_all_tiles().pick_random())
