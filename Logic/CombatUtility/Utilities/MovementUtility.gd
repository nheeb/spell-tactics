class_name MovementUtility extends CombatUtility

func move_entity(entity: Entity, target: Tile):
	entity.move(target)
	if not entity is PlayerEntity:
		combat.animation.callback(entity.visual_entity, "animation_move_to", [target])

func apply_knockback(entity: Entity, direction: Vector2i, force := 1):
	var current_tile := entity.current_tile
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
