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
