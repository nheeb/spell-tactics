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
	if target == null:
		return
	combat.animation.say(enemy.visual_entity, "\"Have another attack.\"")
	combat.animation.camera_reach(target.visual_entity)
	combat.animation.effect(VFX.BILLBOARD_PROJECTILE, enemy.visual_entity, \
		 {"texture_name": "notes", "target": target.visual_entity}).set_flag_extend()
	#target.apply_status_effect(RageEffect.new())
	target.apply_status(Preloaded.STATUS_RAGE)
	combat.animation.effect(VFX.HEX_RINGS, target.visual_entity, {"color": Color.HOT_PINK}).set_flag_extend()
	
