extends SpellLogic

## Usable references:
## spell - Corresponding spell
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the spell was created
## target - The target Tile (if Spell is targetable)
## targets - Array of target tiles (if Spell has multiple targets)


## Here should be the effect
func casting_effect() -> void:
	var counter = 0
	var tiles = combat.player.current_tile.get_surrounding_tiles()
	for tile in tiles:
		for e in tile.entities:
			if "summoned" in e.get_tags():
				counter = counter + 1
	for i in counter:
		combat.cards.draw()



## Spell can be casted
func _is_castable() -> bool:
	var tiles = combat.player.current_tile.get_surrounding_tiles()
	for tile in tiles:
		for e in tile.entities:
			if "summoned" in e.get_tags():
				return true
	return false
