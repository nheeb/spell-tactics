extends EnemyActionLogic

const voice_lines = [
	"This tune will slow him.",
	"Slow tune is my favorite.",
	"Have fun being slowed!"
]

func _execute():
	combat.animation.say(enemy.visual_entity, voice_lines.pick_random())
	combat.animation.camera_reach(target).set_duration(.6)
	combat.animation.effect(VFX.BILLBOARD_PROJECTILE, enemy, \
		 {"texture_name": "notes", "target": target_entity.visual_entity})
	target_entity.apply_status(Preloaded.STATUS_SLOW)
	combat.animation.effect(VFX.HEX_RINGS, combat.player.current_tile, \
		 {"color": Color.YELLOW}).set_flag_extend()
