extends EnemyActionLogic

func _execute():
	combat.animation.say(enemy.visual_entity, "\"Survive, my friend.\"") \
		.set_duration(.6)
	combat.animation.camera_reach(target).set_duration(.6)
	combat.animation.effect(VFX.HEX_RINGS, target, \
		 {"color": Color.GRAY}).set_duration(.6)
	combat.animation.effect(VFX.BILLBOARD_PROJECTILE, enemy, \
		 {"texture_name": "notes", "target": target_entity.visual_entity})
	combat.animation.wait(1)
	(target_entity as HPEntity).armor += 3
	combat.animation.update_hp(target_entity)
	combat.animation.effect(VFX.HEX_RINGS, target, \
		 {"color": Color.DODGER_BLUE}).set_flag_with()

func _evaluate(enemy_tile: Tile, eval: EnemyActionEval) -> EnemyActionEval:
	return eval.multiply(2) if target_entity.hp <= 2 else eval
