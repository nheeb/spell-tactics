extends SpellLogic

const SHROOMS = preload("res://Content/Entities/MediumShrooms.tres")
const SMALL_SHROOMS = preload("res://Content/Entities/SmallShrooms.tres")

## Here should be the effect
func execute() -> void:
	var type = [SHROOMS, SMALL_SHROOMS].pick_random() as EntityType
	var shroom : Entity = type.create_entity(combat, target_tile)
	combat.animation.effect(VFX.HEX_RINGS, target_tile, {"color": Color.DARK_VIOLET})
	combat.animation.show(shroom.visual_entity).set_flag_with()
	if type == SMALL_SHROOMS:
		combat.animation.say(
			combat.player, "Oh no. Those shrooms are smaller than expected.")
	else:
		combat.animation.say(
			combat.player, "What a beautiful set of shrooms.")
	combat.cards.draw()
