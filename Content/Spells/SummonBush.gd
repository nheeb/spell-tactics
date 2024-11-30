extends SpellLogic

const FORT_BUSH = preload("res://Content/Entities/BushFortified.tres")

func execute() -> void:
	var bush := FORT_BUSH.create_entity(combat, target_tile)
	combat.animation.effect(VFX.HEX_RINGS, target_tile, {"color": Color.YELLOW}).set_duration(1.5)
	combat.animation.show(bush.visual_entity).set_flag_with()
