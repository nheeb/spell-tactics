extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	return 1.0

## Executes the move
func execute() -> void:
	var insult_text = "The %s insults your %s." % [enemy.type.pretty_name, ["mother", "honor", "dog", "cats", "existance", "pathetic spells"].pick_random()]
	combat.log.add(insult_text)