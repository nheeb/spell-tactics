class_name SpellLogic extends Object

var spell: Spell

func _init(_spell: Spell):
	spell = _spell
	if spell.type.logic != self.get_script():
		printerr("Weird creation of SpellLogic Object")

## Tests if payment is possible
func is_payment_valid(payment: Array[Game.Energy]) -> bool:
	return Utility.is_energy_cost_payable(payment, get_costs()) is Array

## Returns combination of the other valids. Is being used by PlayerCast to execute the cast
func is_all_valid(payment: Array[Game.Energy]) -> bool:
	return is_unlocked() and is_payment_valid(payment) and is_current_cast_valid()

## Returns a possible payment (if possible)
func get_possible_payment():
	return Utility.is_energy_cost_payable(Game.combat.player_energy, get_costs())

## Deducts the current cards cost from the players engergy
func pay_for_spell(payment: Array[Game.Energy]) -> void:
	if is_payment_valid(payment):
		Game.combat.energy_utility.pay(payment)
	else:
		printerr("Wrong payment done")

## Pays for the costs. Activates the cards effect. Also discards the card from hand
func cast(payment: Array[Game.Energy]) -> void:
	if is_unlocked() and is_payment_valid(payment) and is_current_cast_valid():
		pay_for_spell(payment)
		casting_effect()
		Game.combat.card_utility.discard(spell)
	else:
		printerr("Invalid cast of spell")





## The current costs with all the modifiers if there are any
func get_costs() -> Array[Game.Energy]:
	return spell.type.costs

## This is for overriding if there are general cast-conditions
func is_unlocked() -> bool:
	return true

## This is for overriding if there are conditions for targets
func is_current_cast_valid() -> bool:
	return true

## Most important function for overwriting. Here should be the effect
func casting_effect() -> void:
	pass
