class_name SpellLogic extends Object

var spell: Spell
var combat: Combat
var target  # Entity or Tile or maybe Array[Tile]

func _init(_spell: Spell):
	spell = _spell
	combat = spell.combat
	if spell.type.logic != self.get_script():
		printerr("Weird creation of SpellLogic Object")

## Tests if payment is possible
func is_payment_valid(payment: EnergyStack = null) -> bool:
	return payment.get_possible_payment(get_costs()) != null

## Returns combination of the other valids. Is being used by PlayerCast to execute the cast
func is_all_valid(payment: EnergyStack = null) -> bool:
	return is_unlocked() and is_payment_valid(payment) and is_current_cast_valid()

## Returns a possible payment (if possible)
func get_possible_payment() -> EnergyStack:
	return combat.player_energy.get_possible_payment()

## Deducts the current cards cost from the players engergy
func pay_for_spell(payment: EnergyStack) -> void:
	if is_payment_valid(payment):
		combat.energy.pay(payment)
	else:
		printerr("Wrong payment done")

## Pays for the costs. Activates the cards effect. Also discards the card from hand
func cast(payment: EnergyStack = null) -> void:
	pay_for_spell(payment)
	casting_effect()
	combat.cards.discard(spell)

## The current costs with all the modifiers if there are any
func get_costs() -> EnergyStack:
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
