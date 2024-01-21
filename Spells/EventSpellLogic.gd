class_name EventSpellLogic extends SpellLogic

## Tests if payment is possible
func is_payment_valid(payment: Array[Game.Energy] = []) -> bool:
	return true

## Returns combination of the other valids. Is being used by PlayerCast to execute the cast
func is_all_valid(payment: Array[Game.Energy] = []) -> bool:
	return true

## Returns a possible payment (if possible)
func get_possible_payment():
	return []

## Pays for the costs. Activates the cards effect. Also discards the card from hand
func cast(payment: Array[Game.Energy] = []) -> void:
	casting_effect()

## The current costs with all the modifiers if there are any
func get_costs() -> Array[Game.Energy]:
	return []

## This is for overriding if there are general cast-conditions
func is_unlocked() -> bool:
	return true

## This is for overriding if there are conditions for targets
func is_current_cast_valid() -> bool:
	return true

## Most important function for overwriting. Here should be the effect
func casting_effect() -> void:
	pass
