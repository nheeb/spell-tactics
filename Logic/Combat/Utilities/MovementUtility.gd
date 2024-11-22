class_name MovementUtility extends CombatUtility

func move_entity(entity: Entity, target: Tile, make_animation := true) -> AnimationObject:
	entity.move(target)
	if make_animation:
		return combat.animation.call_method(entity.visual_entity, "animation_move_to", [target])
	return null

func blink_entity(entity: Entity, target: Tile) -> AnimationObject:
	entity.move(target)
	return combat.animation.call_method(entity.visual_entity, "animation_blink_to", [target])

func apply_knockback(entity: Entity, direction: Vector2i, force := 1):
	var current_tile := entity.current_tile
	if current_tile == null:
		# enemy has died, this should be fixed once death-check is only at end of effects
		return
	for i in range(force):
		var next_tile := current_tile.step_in_direction(direction)
		if next_tile:
			if not bool(entity.type.obstacle_mask & next_tile.get_obstacle_layers()):
				move_entity(entity, next_tile)
				current_tile = next_tile
			else:
				break
		else:
			break
