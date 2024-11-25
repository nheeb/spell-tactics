extends SpellLogic

const FORT_BUSH = preload("res://Content/Entities/BushFortified.tres")

func execute() -> void:
	target = target as Tile
	var bush := combat.level.entities.create(target.location, FORT_BUSH, false)
	combat.animation.effect(VFX.HEX_RINGS, target, {"color": Color.YELLOW}).set_duration(1.5)
	combat.animation.show(bush.visual_entity).set_flag_with()
