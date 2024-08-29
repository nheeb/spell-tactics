extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	if enemy.current_tile.distance_to(combat.player.current_tile) > 1:
		match enemy.type.behaviour:
			EnemyEntityType.Behaviour.Fighter:
				return 3.0
	return 0.0

## Executes the move
func execute() -> void:
	var path := combat.level.get_shortest_path(enemy.current_tile, combat.player.current_tile)
	if not path.is_empty():
		var target := path[0]
		if not target.is_blocked():
			combat.movement.move_entity(enemy, target)
