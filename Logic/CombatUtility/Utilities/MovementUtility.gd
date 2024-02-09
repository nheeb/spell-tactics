class_name MovementUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

func move_entity(entity: Entity, target: Tile):
	entity.move(target)
	combat.animation.callback(entity.visual_entity, "animation_move_to", [target])
