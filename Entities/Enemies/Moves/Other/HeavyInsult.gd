extends EnemyActionLogic

func _execute():
	var insult_text = "The %s insults your %s." % [enemy.type.pretty_name, ["mother", "honor", "dog", "cats", "existence", "pathetic spells", "previous jam-entries", "favorite food", "poor social skills", "time management"].pick_random()]
	combat.log.add(insult_text)
	combat.animation.say(enemy.current_tile, insult_text)

func _is_possible(enemy_tile: Tile) -> bool:
	return true
