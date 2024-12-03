extends CombatEventLogic

var smalltalk_lines := [
	"Wow nice weather today.",
	"It's very sunny.",
	"I hope it doesn't start raining soon.",
	"Skrew fighting. Let's go to the lake.",
	"What a pleasant breeze.",
	"Ah yes. Warm sunlight.",
	"Perfect weather for a picnic."
]

func _on_advance(round_number: int) -> void:
	for i in range(randi_range(1, 2)):
		var random_enemy : EnemyEntity = combat.enemies.pick_random() as EnemyEntity
		# TODO check if random enemy still alive / game over?
		combat.animation.say(random_enemy.visual_entity, smalltalk_lines.pick_random()).set_min_duration(1)
