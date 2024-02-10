extends KeywordLogic

## This is called before the cast effect will be resolved
func _before_spell(combat: Combat, spell: Spell):
	pass

## This is called after the cast effect was resolved and the spell was discarded
func _after_spell(combat: Combat, spell: Spell):
	var choice = PlayerChoiceActivity.new("Do you want to keep \"%s\"" % spell.type.pretty_name, \
					[true, false], ["Yes", "No"])
	combat.animation.wait(.5)
	combat.animation.player_choice(choice)
	await choice.resolved
	if choice.get_result():
		combat.cards.fetch_from_discard(spell)

## Uncomment this method if you want to alter the spell's costs
#func _get_updated_energy_price(price: EnergyStack, spell: Spell) -> EnergyStack:
	#return price

