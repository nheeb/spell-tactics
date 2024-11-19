extends SpellLogic

const TOTEM = preload("res://Content/Entities/EarthTotem.tres")

## Here should be the effect
func casting_effect() -> void:
	target = target as Tile
	var totem := combat.level.entities.create(target.location, TOTEM, false)
	combat.animation.effect(VFX.HEX_RINGS, target, {"color": Color.SADDLE_BROWN}).set_duration(1.5)
	combat.animation.show(totem.visual_entity).set_flag_with()
