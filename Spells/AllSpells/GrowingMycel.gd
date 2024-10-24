extends SpellLogic

const SHROOMS = preload("res://Entities/Environment/MediumShrooms.tres")
const SMALL_SHROOMS = preload("res://Entities/Environment/SmallShrooms.tres")

## Here should be the effect
func casting_effect() -> void:
	target = target as Tile
	var type = [SHROOMS, SMALL_SHROOMS].pick_random()
	var shroom : Entity = combat.level.entities.create(target.location, type, false)
	combat.animation.effect(VFX.HEX_RINGS, target, {"color": Color.DARK_VIOLET})
	combat.animation.show(shroom.visual_entity).set_flag_with()
	if type == SMALL_SHROOMS:
		combat.animation.say(
			combat.player, "Oh no. Those shrooms are smaller than expected.")
	else:
		combat.animation.say(
			combat.player, "What a beautiful set of shrooms.")
	combat.cards.draw()
