extends EnemyActionLogic

const STATUS_SHOT_CHARGED = preload(
	"res://Content/Status/EnemyMoves/ShotCharged.tres"
)

func _execute():
	combat.animation.say(enemy.visual_entity, "Super triple shot!").set_duration(.6)
	for i in range(3):
		var line := enemy.current_tile.get_line(target_entity.current_tile)
		var hit_tile := Utility.array_get_first_filtered_value(
			line,
			func (tile: Tile): return tile.get_highest_cover() > 0
		) as Tile
		assert(hit_tile)
		combat.attack.projectile_animation(
			enemy.current_tile, hit_tile, target_entity.current_tile
			)
		var hit_entities := hit_tile.get_entities_with_highest_cover()
		var dmg := enemy.strength
		combat.animation.wait()
		for hit_entity in hit_entities:
			hit_entity.inflict_damage_with_visuals(dmg).set_flag_extend().set_max_duration(.6)
			combat.animation.say(hit_entity, "%s DAMAGE" % dmg,
				{"font_size": 42, "color": Color.RED}).set_flag_extend().set_max_duration(.6)
		await combat.action_stack.force_combat_change_update()
	enemy.remove_status(STATUS_SHOT_CHARGED)
