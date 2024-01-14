class_name PlayerDrain extends PlayerAction

var target_tile: Tile

func is_valid() -> bool:
	if Game.combat.current_phase != Combat.RoundPhase.Spell:
		return false
	# TODO Test if tile is reachable and drainable
	return true

func execute() -> void:
	# TODO drain the tile
	for entity in target_tile.entities:
		entity = entity as Entity
		#Game.combat.energy_utility.gain(entity. ...)
	pass
