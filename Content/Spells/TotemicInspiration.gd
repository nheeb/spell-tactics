extends SpellLogic

func execute() -> void:
	var counter = 0
	var tiles = combat.player.current_tile.get_surrounding_tiles()
	for tile in tiles:
		for e in tile.entities:
			if "summoned" in e.get_tags():
				counter += 1
	for i in counter:
		combat.cards.draw()

func is_executable() -> bool:
	var tiles = combat.player.current_tile.get_surrounding_tiles()
	for tile in tiles:
		for e in tile.entities:
			if "summoned" in e.get_tags():
				return true
	return false
