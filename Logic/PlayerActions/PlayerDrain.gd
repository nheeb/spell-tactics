class_name PlayerDrain extends PlayerAction

var target_tile: Tile

func _init(tile: Tile) -> void:
	target_tile = tile
	action_string = "Drain tile %s" % target_tile

func is_valid(combat: Combat) -> bool:
	if combat.current_phase != Combat.RoundPhase.Spell:
		return false
	# TODO Test if tile is reachable and drainable
	return true

func execute(combat: Combat) -> void:
	# TODO drain the tile
	for entity in target_tile.entities:
		entity = entity as Entity
		#Game.combat.energy_utility.gain(entity. ...)
	pass
