extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	if enemy.get_status_effect("snare"):
		return 0.0
	if enemy.current_tile.distance_to(combat.player.current_tile) > 1:
		match enemy.type.behaviour:
			EnemyEntityType.Behaviour.Fighter:
				return 4.0
	return 0.0

## Executes the move
func execute() -> void:
	combat.animation.say(enemy.visual_entity, "Sprint").set_max_duration(.5)
	var path := combat.level.get_shortest_path(enemy.current_tile, combat.player.current_tile)
	for i in range(2):
		if not path.is_empty():
			var target : Tile = path.pop_front()
			if not target.is_blocked():
				combat.movement.move_entity(enemy, target)
