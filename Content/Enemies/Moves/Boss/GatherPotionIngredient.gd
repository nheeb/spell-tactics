extends EnemyActionLogic

const THROW_DURATION = .7

func get_witch() -> EnemyEntity:
	return combat.get_all_enemies().filter(
		func (e: EnemyEntity):
			return "witch" in e.get_enemy_type().internal_name
	).front()

func throw_animation(vis_ent: Node3D, start: Vector3, end: Vector3, bow_height := 2.0):
	var tween := VisualTime.new_tween()
	tween.tween_method(
			func (p: float):
				var pos := start.lerp(end, p)
				var height := (1.0 - pow(2.0 * (p - .5), 2.0)) * bow_height
				vis_ent.global_position = pos + Vector3.UP * height,
		0.0, 1.0, THROW_DURATION)

func _execute():
	combat.animation.say(enemy.visual_entity, "This might help.")
	combat.animation.callable(
		throw_animation.bind(
			target_entity.visual_entity,
			target_entity.visual_entity.global_position,
			get_witch().visual_entity.global_position + Vector3.UP
		)
	).set_duration(THROW_DURATION)
	target_entity.die()
	combat.events.add_to_enemy_meter()

func _is_possible(enemy_tile: Tile) -> bool:
	return get_witch() and target_tile.is_next_to(enemy_tile)

func _get_target_pool() -> Array:
	var all_targets := []
	var tiles := enemy.current_tile.get_surrounding_tiles(3)
	for t in tiles:
		for e in t.entities:
			if "shroom" in e.get_tags():
				all_targets.append(e)
	return all_targets
