extends EnemyActionLogic

const voice_lines = [
	"Survive, my friend.",
	"Don't die, my fellow Goblin.",
	"I will save you!"
]

func _execute():
	combat.animation.say(enemy.visual_entity, voice_lines.pick_random()).set_duration(.6)
	combat.animation.camera_reach(target).set_duration(.6)
	combat.animation.effect(VFX.BILLBOARD_PROJECTILE, enemy, \
		 {"texture_name": "notes", "target": target_entity.visual_entity})
	combat.animation.wait(.1)
	var old_hp := target_entity.hp + target_entity.armor
	target_entity.inflict_heal_with_visuals(3, true)
	combat.animation.effect(VFX.HEX_RINGS, target, \
		 {"color": Color.DODGER_BLUE}).set_flag_extend()
	if old_hp <= 2:
		combat.animation.say(target_entity, "Damn, that was close.")

func _evaluate(enemy_tile: Tile, eval: EnemyActionEval) -> EnemyActionEval:
	var factor := 1.0
	if not target_entity.is_wounded():
		factor = .5
	elif target_entity.hp + target_entity.armor <= 2:
		factor = 2.0
	return eval.multiply(factor)
