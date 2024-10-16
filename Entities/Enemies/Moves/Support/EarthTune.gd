extends EnemyActionLogic

func _execute():
	combat.animation.say(enemy.visual_entity, "\"Survive, my friend.\"")
	combat.animation.camera_reach(target).set_delay(.3).set_flag_with()
	combat.animation.effect(VFX.HEX_RINGS, combat.player.current_tile, \
		 {"color": Color.RED}).set_flag_with()
	combat.animation.effect(VFX.BILLBOARD_PROJECTILE, enemy, \
		 {"texture_name": "notes", "target": target_entity.visual_entity})
	(target_entity as HPEntity).armor += 3
	combat.animation.update_hp(target_entity)

func _evaluate(enemy_tile: Tile, eval: EnemyActionEval) -> EnemyActionEval:
	return eval.multiply(2) if target_entity.hp <= 2 else eval
