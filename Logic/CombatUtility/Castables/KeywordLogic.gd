class_name KeywordLogic extends Object

func before_spell(spell: Spell):
	_before_spell(spell.combat, spell)

func _before_spell(combat: Combat, spell: Spell):
	pass

func after_spell(spell: Spell):
	_after_spell(spell.combat, spell)

func _after_spell(combat: Combat, spell: Spell):
	pass

func get_updated_energy_price(price: EnergyStack, spell: Spell) -> EnergyStack:
	if has_method("_get_updated_energy_price"):
		call("_get_updated_energy_price", price, spell)
	return price

#func _get_updated_energy_price(price: EnergyStack, spell: Spell) -> EnergyStack:
	#return price

func is_unlocked(spell: Spell) -> bool:
	return _is_unlocked(spell.combat, spell)

func _is_unlocked(combat: Combat, spell: Spell) -> bool:
	return true
