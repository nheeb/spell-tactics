extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	match enemy.type.behaviour:
		EnemyEntityType.Behaviour.Fighter:
			var dist_to_player = Utility.tile_distance(combat.player.current_tile, enemy.current_tile)
			return 5.0 if dist_to_player <= 1 else 0.0
	return 0.0

## Executes the move
func execute() -> void:
	var chance : float = 50.0 + enemy.accuracy * 10.0
	var dmg : int = enemy.strength
	combat.animation.say(enemy.visual_entity, "Punching! (%.0f%% hit chance)" % chance)
	combat.animation.effect(VFX.HEX_RINGS, combat.player.current_tile, {"color": Color.RED}).set_flag_with()
	
	var hit := Utility.random_hit(chance)
	if hit:
		combat.player.inflict_damage(dmg)
		combat.animation.say(enemy.visual_entity, "HIT!").set_max_duration(.3)
		combat.animation.update_hp(combat.player)
		combat.animation.say(combat.player.visual_entity, "%s DAMAGE" % dmg, {"font_size": 42, "color": Color.RED}).set_flag_with()
	else:
		combat.animation.say(enemy.visual_entity, "Punch missed.")
