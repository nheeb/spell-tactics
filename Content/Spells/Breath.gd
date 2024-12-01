extends SpellLogic

func execute() -> void:
	combat.cards.draw()
	combat.castables.get_active_from_name("Drain").add_to_bonus_uses(1)

func is_selectable() -> bool:
	for tile in combat.player.current_tile.get_surrounding_tiles():
		for e in tile.entities:
			if e is HPEntity:
				if e.team == HPEntityType.Teams.Evil:
					return false
	return true

func is_castable() -> bool:
	for tile in combat.player.current_tile.get_surrounding_tiles():
		for e in tile.entities:
			if e is HPEntity:
				if e.team == HPEntityType.Teams.Evil:
					return false
	return true
