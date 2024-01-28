extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	match enemy.type.behaviour:
		EnemyEntityType.Behaviour.Archer:
			return 6.0
	return 0.0

## Executes the move
func execute() -> void:
	combat.animation.say(enemy.visual_entity, "\"Eat my arrow!\"")
	combat.animation.camera_follow(combat.player.visual_entity)
	combat.animation.wait(1.0)
	var line := combat.level.get_line(enemy.current_tile, combat.player.current_tile)
	combat.animation.wait(2.0)
	var total_cover := 0
	for tile in line:
		combat.animation.effect(VFX.HEX_COLOR, tile).set_flag_with()
		for ent in tile.entities:
			var cover := ent.type.cover_value
			if cover != 0:
				total_cover += cover
				combat.animation.say(tile, "[%s]" % cover).set_flag_with().set_delay(.9)
	var chance := enemy.accuracy * 10.0 + 40.0 - total_cover * 10.0
	var dmg := enemy.strength
	combat.animation.say(enemy.visual_entity, "Shooting! (%.0f%% hit chance)" % chance)
	combat.animation.effect(VFX.HEX_RINGS, combat.player.current_tile, {"color": Color.RED}).set_flag_with()
	
	var hit := Utility.random_hit(chance)
	if hit:
		combat.player.inflict_damage(dmg)
		combat.animation.say(enemy.visual_entity, "HIT!").set_max_duration(.3)
		combat.animation.update_hp(combat.player)
		combat.animation.say(combat.player.visual_entity, "%s DAMAGE" % dmg, {"font_size": 42, "color": Color.RED}).set_flag_with()
	else:
		combat.animation.say(enemy.visual_entity, "Shot missed.")

