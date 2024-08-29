extends EnemyActionLogic

func _execute():
	combat.animation.say(enemy.visual_entity, "\"Eat my arrow!\"")

	var hit := combat.attack.enemy_shoot_projectile(enemy, 0, "arrow")
	var dmg := enemy.strength
	if hit:
		target.inflict_damage_with_visuals(dmg)
		combat.animation.say(target.visual_entity, "%s DAMAGE" % dmg, {"font_size": 42, "color": Color.RED})
	else:
		combat.animation.say(enemy.visual_entity, "Shot missed.")
