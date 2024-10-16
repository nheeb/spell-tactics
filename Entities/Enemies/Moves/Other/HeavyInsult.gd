extends EnemyActionLogic

func _execute():
	var insult_text = "The %s insults your %s." % [enemy.type.pretty_name, ["mother", "honor", "dog", "cats", "existence", "pathetic spells", "previous jam-entries", "favorite food", "poor social skills", "time management"].pick_random()]
	combat.animation.say(enemy.current_tile, insult_text)
