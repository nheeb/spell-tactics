class_name PlayerDrain extends PlayerAction

var target_tile: Tile

func _init(tile: Tile) -> void:
	target_tile = tile
	action_string = "Drain tile %s" % target_tile

func is_valid(combat: Combat) -> bool:
	if combat.current_phase != Combat.RoundPhase.Spell:
		return false
	if combat.energy.drains_done_this_turn >= combat.player.traits.max_drains:
		return false
	# Check distance, only adjacent tiles can be drained
	if Utility.tile_distance(combat.player.current_tile, target_tile) <= 1:
		if target_tile.is_drainable():
			return true
	return false

func execute(combat: Combat) -> void:
	#var drainable_ents = target_tile.entities.filter(func(e): e.is_drainable())
	
	combat.energy.add_a_drain()
	
	for entity in target_tile.entities:
		entity = entity as Entity
		var energy_stack : EnergyStack = null
		#if not entity.is_drainable() and not entity.type.is_terrain:
			#continue
		# entity.drain() removes the energy from that entity as a side-effect
		if entity.is_drainable():
			energy_stack = entity.drain()
			combat.energy.gain(energy_stack)
		combat.animation.callback(entity.visual_entity, "visual_drain").set_max_duration(.5)
		if energy_stack:
			combat.animation.callback(entity.visual_entity, "spawn_energy_orbs",\
					[energy_stack, combat.player.visual_entity.orbital_movement_body])\
					.set_max_duration(.5).set_flag_with()
			combat.animation.callback(combat.ui.cards3d.energy_ui, "spawn_energy_orbs",\
					[energy_stack]).set_max_duration(.5).set_flag_with()
		for tag in entity.get_tags():
			combat.log.register_incident("drained_tag_%s" % tag)
	
	# TODO animation_queue send entity got drained signal to the visual instance
