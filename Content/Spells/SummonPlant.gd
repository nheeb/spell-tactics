extends SpellLogic

const BUSH = preload("res://Content/Entities/Bush.tres")

func execute() -> void:
	var plant_pool := data.get("plant_pool", [BUSH]) as Array
	var plant_type := plant_pool.pick_random() as EntityType
	assert(plant_type)
	combat.animation.effect(VFX.HEX_RINGS, target_tile, {"color": Color.YELLOW}).set_duration(1.5)
	combat.animation.record_start()
	var plant := plant_type.create_entity(combat, target_tile)
	plant.apply_status(Preloaded.STATUS_FORTIFIED)
	await combat.action_stack.wait()
	combat.animation.record_finish_as_subqueue().set_flag_with()
