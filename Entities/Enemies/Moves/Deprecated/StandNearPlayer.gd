extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	if enemy.current_tile.distance_to(combat.player.current_tile) <= 1:
		return 1.0
	return 0.0

## Executes the move
func execute() -> void:
	pass
