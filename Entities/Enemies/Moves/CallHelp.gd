extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	match enemy.type.behaviour:
		EnemyEntityType.Behaviour.Support:
			return 2.0
	return 0.0

## Executes the move
func execute() -> void:
	combat.animation.say(enemy.visual_entity, "\"We need more Goblins!\"", \
		{"color": Color.WHITE, "font_size": 72})
	combat.animation.effect(VFX.BILLBOARD_EFFECT, enemy.visual_entity, \
		{"grow_size": 1.5, "texture_name": "notes", "color": Color.RED}) \
		.set_max_duration(1)
	combat.events.add_to_enemy_meter(2)
