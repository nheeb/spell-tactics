extends EntityLogic

func on_create(): # Happens when the entity is created (deserialized or summoned)
	combat.spell_casted_successfully.connect(give_energy)

var first_time_lock := true

func give_energy(spell_ref = null) -> void:
	if first_time_lock:
		first_time_lock = false
		return
	if combat.player.current_tile.distance_to(entity.current_tile) <= 1:
		combat.animation.camera_reach(entity.visual_entity)
		combat.animation.effect(VFX.HEX_RINGS, entity.visual_entity, {"color": Color.DARK_VIOLET}).set_max_duration(.5)
		combat.energy.gain(EnergyStack.string_to_energy("D")).set_flag_with()
		combat.animation.say(entity.visual_entity, "+1 Decay").set_flag_with()

func on_delete(): # Happens when the entity enters the graveyard
	if combat.spell_casted_successfully.is_connected(give_energy):
		combat.spell_casted_successfully.disconnect(give_energy)

func on_death(): # Happens when hp entity dies (before its being moved to the graveyard)
	pass

