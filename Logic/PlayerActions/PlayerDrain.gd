class_name PlayerDrain extends PlayerAction

var target_tile: Tile

func _init(tile: Tile) -> void:
	target_tile = tile
	action_string = "Drain tile %s" % target_tile

func is_valid(combat: Combat) -> bool:
	if combat.current_phase != Combat.RoundPhase.Spell:
		return false
	# Check distance, only adjacent tiles can be drained
	if Utility.tile_distance(combat.player.current_tile, target_tile) <= 1:
		if target_tile.is_drainable():
			return true
	return false

func execute(combat: Combat) -> void:
	#var drainable_ents = target_tile.entities.filter(func(e): e.is_drainable())
	
	for entity in target_tile.entities:
		entity = entity as Entity
		if not entity.is_drainable():
			continue
		# entity.drain() removes the energy from that entity as a side-effect
		combat.energy.gain(entity.drain())
		
	# TODO animation_queue send entity got drained signal to the visual instance
