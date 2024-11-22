extends EntityLogic

func on_create():
	pass

const BONES = preload("res://Content/Entities/Bones.tres")

func on_graveyard():
	pass

func on_death(): # Happens when HP Entity dies
	var tile := entity.current_tile
	var bones := combat.level.entities.create(tile.location, BONES, false)
	combat.animation.show(bones.visual_entity).set_flag_with()
	combat.animation.effect(VFX.HEX_RINGS, tile, {"color": Color.YELLOW}).set_max_duration(.6).set_flag_extend()
	#combat.events.add_to_enemy_meter()
	var drain_active := Utility.array_safe_get(
		combat.actives.filter(
			func (a: Active): return a.type.internal_name == "Drain"
		), 0) as Active
	drain_active.add_to_bonus_uses(1)
