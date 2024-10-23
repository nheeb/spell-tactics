extends SpellLogic

func casting_effect() -> void:
	for i in range(2):
		combat.cards.draw()

func _is_castable() -> bool:
	for tile in combat.player.current_tile.get_surrounding_tiles():
		for e in tile.entities:
			if e is HPEntity:
				if e.team == HPEntityType.Teams.Evil:
					return false
	return true
