class_name MovementUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

func move_entity(entity: Entity, target: Tile):
	# TODO Nils move entity to target tile
	combat.animation_queue.append(AnimationObject.new(entity.visual_entity, "animation_move_to", [target]))
	pass
