class_name MovementUtility extends CombatUtility

func move_entity(entity: Entity, target: Tile):
	entity.move(target)
	combat.animation.callback(entity.visual_entity, "animation_move_to", [target])
