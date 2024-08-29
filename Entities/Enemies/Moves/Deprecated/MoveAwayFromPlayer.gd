extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	var possible := false
	var dir := combat.player.current_tile.direction_to(enemy.current_tile)
	var target := enemy.current_tile.step_in_direction(dir)
	if target:
		if not (enemy.type.obstacle_mask & target.get_obstacle_layers()):
			possible = true
	if not possible:
		return 0.0
	if enemy.current_tile.distance_to(combat.player.current_tile) > 1:
		match enemy.type.behaviour:
			EnemyEntityType.Behaviour.Support:
				return 3.0
	return 0.0

## Executes the move
func execute() -> void:
	var dir := combat.player.current_tile.direction_to(enemy.current_tile)
	var target := enemy.current_tile.step_in_direction(dir)
	if target:
		if not (enemy.type.obstacle_mask & target.get_obstacle_layers()):
			combat.movement.move_entity(enemy, target)
