extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	if combat.attack.get_other_enemies(enemy).is_empty():
		return 0.0
	match enemy.type.behaviour:
		EnemyEntityType.Behaviour.Support:
			return 2.0
	return 0.0

## Executes the move
func execute() -> void:
	var target : EnemyEntity = combat.attack.get_other_enemies(enemy).pick_random() as EnemyEntity
	combat.animation.say(enemy.visual_entity, "\"This tune will protect you.\"")
	combat.animation.camera_reach(target.visual_entity)
	combat.animation.effect(VFX.BILLBOARD_PROJECTILE, enemy.visual_entity, \
		 {"texture_name": "notes", "target": target.visual_entity}).set_flag_extend()
	target.armor += 2
	combat.animation.effect(VFX.HEX_RINGS, target.visual_entity, {"color": Color.YELLOW})
	combat.animation.update_hp(target).set_flag_with()
	
