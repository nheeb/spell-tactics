extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	return 0.7

## Executes the move
func execute() -> void:
	var insult_text = "The %s insults your %s." % [enemy.type.pretty_name, ["mother", "honor", "dog", "cats", "existence", "pathetic spells", "previous jam-entries", "favorite food", "poor social skills", "time management"].pick_random()]
	combat.log.add(insult_text)
	combat.animation.say(enemy.current_tile, insult_text)
