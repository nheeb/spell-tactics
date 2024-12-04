class_name AttackUtility extends CombatUtility

########################################
## Common Utility Methods for Enemies ##
########################################

func get_other_enemies(enemy: EnemyEntity) -> Array[EnemyEntity]:
	var enemies := combat.get_all_enemies()
	return enemies.filter(func(e): return e != enemy)

#########################################
## Common ANIMATOR Methods for Enemies ##
#########################################

## ANIMATOR
func projectile_animation(source: CombatObject, destination: CombatObject, \
			aimed_target: CombatObject, texture_name := "arrow") -> AnimationObject:
	combat.animation.record_start()
	if DebugInfo.SHOW_ENEMY_PROJECTILE_INFO:
		combat.animation.effect(
			VFX.LINE, source.node3d,
			{
				"start_node": source.node3d,
				"end_node": aimed_target.node3d,
				"duration": 1.0
			}
		).set_max_duration(.1)
	combat.animation.wait(.6)
	combat.animation.effect(VFX.HEX_RINGS, aimed_target, {"color": Color.RED}).set_flag_with()
	combat.animation.effect(VFX.HEX_COLOR, destination).set_flag_with()
	combat.animation.effect(VFX.BILLBOARD_PROJECTILE, source, \
		 {"texture_name": texture_name, "target": destination.node3d})
	return combat.animation.record_finish_as_subqueue()

## ANIMATOR
func punch_animation(source: CombatObject, target: CombatObject) -> AnimationObject:
	combat.animation.record_start()
	combat.animation.effect(VFX.HEX_COLOR, target)
	combat.animation.effect(VFX.HEX_RINGS, target, {"color": Color.RED}).set_flag_with()
	return combat.animation.record_finish_as_subqueue()

#######################################
## Common ACTION Methods for Enemies ##
#######################################

## ACTION
func summon_enemy(enemy_type: EnemyEntityType, tile: Tile, color := Color.RED) -> AnimationSubQueue:
	var anims : Array[AnimationObject] = []
	var e = combat.level.entities.create(tile.location, enemy_type, false)
	combat.enemies.append(e)
	anims.append(combat.animation.camera_reach(e.visual_entity))
	anims.append(combat.animation.wait(.3))
	anims.append(combat.animation.show(e.visual_entity))
	anims.append(combat.animation.effect(VFX.HEX_RINGS, e.visual_entity, {"color": color}))
	return combat.animation.reappend_as_subqueue(anims)

########################
## DEPRECATED Garbage ##
########################

func enemy_shoot_projectile(enemy: EnemyEntity, projectile_bonus := 0, texture_name := "arrow") -> bool:
	push_warning("DEPRECATED enemy_shoot_projectile")
	combat.animation.wait(.5)
	var line := combat.level.get_line(enemy.current_tile, combat.player.current_tile)
	if DebugInfo.SHOW_ENEMY_PROJECTILE_INFO:
		combat.animation.wait(1.0)
		combat.animation.effect(
			VFX.LINE, enemy.current_tile,
			{
				"start_node": enemy.current_tile.node3d,
				"end_node": combat.player.current_tile.node3d,
				"duration": 2.0
			}
		).set_max_duration(.1)
	var total_cover := 0
	for tile in line:
		if DebugInfo.SHOW_ENEMY_PROJECTILE_INFO:
			combat.animation.effect(VFX.HEX_COLOR, tile).set_flag_with()
		for ent in tile.entities:
			var cover := ent.cover
			if cover != 0:
				total_cover += cover
				if DebugInfo.SHOW_ENEMY_PROJECTILE_INFO:
					combat.animation.say(tile, "[%s]" % cover).set_flag_with().set_delay(.9)
	
	var chance : float = clamp(enemy.accuracy * 10.0 + projectile_bonus * 10.0 - total_cover * 10.0, 0.0, 100.0)

	combat.animation.say(enemy.visual_entity, "Shooting! (%.0f%% hit chance)" % chance)
	combat.animation.effect(VFX.HEX_RINGS, combat.player.current_tile, \
		 {"color": Color.RED}).set_flag_with()
	combat.animation.effect(VFX.BILLBOARD_PROJECTILE, enemy.visual_entity, \
		 {"texture_name": texture_name, "target": combat.player.visual_entity}).set_flag_extend()
	combat.animation.camera_reach(combat.player.visual_entity).set_flag_extend()
	
	var hit := Utility.random_hit(chance)
	return hit

func enemy_punch(enemy: EnemyEntity, attack_bonus := 0) -> bool:
	push_warning("DEPRECATED enemy_punch")
	var chance : float = max(0.0, attack_bonus * 10.0 + enemy.accuracy * 10.0)

	combat.animation.say(enemy.visual_entity, "Punching! (%.0f%% hit chance)" % chance)
	combat.animation.effect(VFX.HEX_RINGS, combat.player.current_tile, {"color": Color.RED}).set_flag_with()
	
	var hit := Utility.random_hit(chance)
	if not hit:
		combat.animation.say(enemy.visual_entity, "Punch missed.")
	return hit
