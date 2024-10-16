extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	match enemy.type.behaviour:
		EnemyEntityType.Behaviour.Archer:
			return 6.0
	return 0.0

## Executes the move
func execute() -> void:
	if forced:
		if enemy.forced_movement_name == "DoNothing":
			enemy.forced_movement_name = ""
	
	combat.animation.say(enemy.visual_entity, "\"This arrow won't miss!\"")

	var hit := combat.attack.enemy_shoot_projectile(enemy, 3, "arrow")
	var dmg := enemy.strength * 2
	if hit:
		combat.player.inflict_damage_with_visuals(dmg)
		combat.animation.say(combat.player.visual_entity, "%s DAMAGE" % dmg, {"font_size": 42, "color": Color.RED})
	else:
		combat.animation.say(enemy.visual_entity, "Shot missed.")
