extends EnemyActionLogic

func _execute():
	combat.animation.say(enemy.visual_entity, "\"How about two actions?.\"")
	combat.animation.camera_reach(target).set_duration(.6)
	combat.animation.effect(VFX.HEX_RINGS, target, \
		 {"color": Color.YELLOW}).set_duration(.6)
	combat.animation.effect(VFX.BILLBOARD_PROJECTILE, enemy, \
		 {"texture_name": "notes", "target": target_entity.visual_entity})
	target_entity.apply_status(Preloaded.STATUS_RAGE)
