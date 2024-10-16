extends EnemyActionLogic

func _execute():
	combat.animation.say(enemy.visual_entity, "\"This tune will slow him.\"")
	combat.animation.camera_reach(target).set_delay(.3).set_flag_with()
	combat.animation.effect(VFX.HEX_RINGS, combat.player.current_tile, \
		 {"color": Color.YELLOW}).set_flag_with()
	combat.animation.effect(VFX.BILLBOARD_PROJECTILE, enemy, \
		 {"texture_name": "notes", "target": target_entity.visual_entity})
	target_entity.apply_status(Preloaded.STATUS_SLOW)
