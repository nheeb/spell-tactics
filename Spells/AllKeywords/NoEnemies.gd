extends KeywordLogic

## This is called before the cast effect will be resolved
func _before_spell(combat: Combat, spell: Spell):
	pass

## This is called after the cast effect was resolved
func _after_spell(combat: Combat, spell: Spell):
	pass

## Uncomment this method if you want to alter the spell's costs
#func _get_updated_energy_price(price: EnergyStack, spell: Spell) -> EnergyStack:
	#return price

## Uncomment this method if you want to add a locking condition
func _is_unlocked(combat: Combat, spell: Spell) -> bool:
	var unlock = not combat.player.current_tile.get_surrounding_tiles().any(\
			func(t): return len(t.get_enemies()) > 0)
	return unlock
