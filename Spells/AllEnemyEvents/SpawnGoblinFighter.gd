extends EventSpellLogic

## Usable references:
## spell - Corresponding event
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the spell was created

func get_event_length() -> int:
	return 1

const GOBLIN = preload("res://Entities/Enemies/Goblin.tres")

func event_effect(round_number: int) -> void:
	var location = combat.level.get_center_tile().location
	var goblin = combat.level.entities().create_entity(location, GOBLIN, false)
	combat.enemies.append(goblin)
	combat.animation.camera_reach(goblin.visual_entity)
	combat.animation.wait(.4)
	combat.animation.show(goblin.visual_entity)
	combat.animation.effect(VFX.HEX_RINGS, goblin.visual_entity, {"color": Color.RED})
