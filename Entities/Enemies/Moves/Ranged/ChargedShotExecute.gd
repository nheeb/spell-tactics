extends EnemyActionLogic

const STATUS_SHOT_CHARGED = preload(
	"res://Spells/AllStatusEffects/EnemyMoves/ShotCharged.tres"
)

func _execute():
	combat.animation.say(enemy, "Here is my heavy shot!")
	var line := combat.level.get_line(enemy.current_tile, combat.player.current_tile)
	if DebugInfo.SHOW_ENEMY_PROJECTILE_INFO:
		combat.animation.wait(1.0)
		combat.animation.effect(VFX.LINE, enemy.current_tile, {"start_node": enemy.current_tile, "end_node": combat.player.current_tile, "duration": 2.0}).set_max_duration(.1)
	var blocking_entity: Entity = null
	for tile in line:
		if DebugInfo.SHOW_ENEMY_PROJECTILE_INFO:
			combat.animation.effect(VFX.HEX_COLOR, tile).set_flag_with()
		for ent in tile.entities:
			var cover := ent.type.cover_value
			if cover >= 2:
				blocking_entity = ent
				break
	combat.animation.effect(VFX.HEX_RINGS, target_tile, \
		 {"color": Color.RED}).set_flag_with()
	if blocking_entity:
		combat.animation.effect(VFX.HEX_RINGS, blocking_entity.current_tile, \
			 {"color": Color.YELLOW}).set_flag_with()
	combat.animation.wait(.3)
	var target_node_3d = blocking_entity.visual_entity if blocking_entity else target_entity.visual_entity
	combat.animation.camera_reach(target_node_3d)
	combat.animation.effect(VFX.BILLBOARD_PROJECTILE, enemy.visual_entity, \
		 {
			"texture_name": "arrow", 
			"target": target_node_3d
		}).set_flag_extend()
	if blocking_entity:
		blocking_entity.die()
	else:
		if target is not HPEntity:
			push_error("Wrong target for this enemy action")
		target.inflict_damage_with_visuals(args.get_arg(0, enemy.strength * 3))
	enemy.remove_status(STATUS_SHOT_CHARGED)
