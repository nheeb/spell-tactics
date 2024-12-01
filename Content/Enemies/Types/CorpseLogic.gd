extends EntityLogic

const BONES = preload("res://Content/Entities/Bones.tres")

func on_death(): # Happens when HP Entity dies
	var tile := entity.current_tile
	var bones := combat.level.entities.create(tile.location, BONES, false)
	combat.animation.show(bones.visual_entity).set_flag_with()
	combat.animation.effect(VFX.HEX_RINGS, tile, {"color": Color.YELLOW}).set_max_duration(.6).set_flag_extend()
	#combat.events.add_to_enemy_meter()
	combat.castables.get_active_from_name("Drain").add_to_bonus_uses(1)
