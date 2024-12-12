extends EnemyActionLogic

const voice_lines = [
	"Eat my arrow!",
	"I'm gonna shoot him!",
	"Take that, filthy racoon!",
	"Can't miss with the recent update.",
	"Don't hide behind trees!"
]

func _execute():
	var dmg := enemy.strength
	combat.animation.say(enemy.visual_entity, voice_lines.pick_random()).set_duration(.6)
	var line := enemy.current_tile.get_line(target_entity.current_tile)
	var hit_tile := Utility.array_get_first_filtered_value(
		line,
		func (tile: Tile): return tile.get_highest_cover() > 0
	) as Tile
	assert(hit_tile)
	combat.animation.camera_reach(target_entity).set_duration(.6)
	combat.attack.projectile_animation(enemy.current_tile, hit_tile, target_entity.current_tile)
	hit_tile.inflict_damage_with_visuals(dmg)
