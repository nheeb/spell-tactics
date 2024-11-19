extends EntityLogic

func on_summon():
	
	TimedEffect.new_end_phase_trigger_from_callable(
		give_armor
	).register(combat)

func give_armor() -> void:
	if combat.player.current_tile.distance_to(entity.current_tile) <= 1:
		combat.animation.camera_reach(entity.visual_entity)
		combat.animation.effect(VFX.HEX_RINGS, entity.visual_entity, {"color": Color.SADDLE_BROWN}).set_max_duration(.5)
		combat.player.armor += 2
		combat.animation.update_hp(combat.player).set_flag_with()
