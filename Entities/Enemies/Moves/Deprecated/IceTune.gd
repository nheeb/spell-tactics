extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	match enemy.type.behaviour:
		EnemyEntityType.Behaviour.Support:
			return 2.0
	return 0.0

## Executes the move
func execute() -> void:
	combat.animation.say(enemy.visual_entity, "\"This tune will slow him.\"")

	var hit := combat.attack.enemy_shoot_projectile(enemy, 0, "notes")
	var dmg := 1
	if hit:
		combat.player.inflict_damage_with_visuals(dmg)
		combat.animation.say(combat.player.visual_entity, "%s DAMAGE" % dmg, {"font_size": 42, "color": Color.RED})
		#combat.player.apply_status_effect(SlowEffect.new())
		combat.player.apply_status(Preloaded.STATUS_SLOW)
	else:
		combat.animation.say(enemy.visual_entity, "Shot missed.")
