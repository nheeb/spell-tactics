extends SpellLogic

func casting_effect() -> void:
	combat.cards.draw()
	combat.energy.gain(EnergyStack.string_to_energy("H"), combat.player)

func _is_selectable() -> bool:
	for tile in combat.player.current_tile.get_surrounding_tiles():
		for e in tile.entities:
			if e is HPEntity:
				if e.team == HPEntityType.Teams.Evil:
					return false
	return true

func _is_castable() -> bool:
	for tile in combat.player.current_tile.get_surrounding_tiles():
		for e in tile.entities:
			if e is HPEntity:
				if e.team == HPEntityType.Teams.Evil:
					return false
	return true
