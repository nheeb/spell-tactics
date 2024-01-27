class_name EventSpellLogic extends SpellLogic

### Tests if payment is possible
#func is_payment_valid(payment: EnergyStack = null) -> bool:
	#return true
#
### Returns combination of the other valids. Is being used by PlayerCast to execute the cast
#func is_all_valid(payment: EnergyStack = null) -> bool:
	#return true
#
### Returns a possible payment (if possible)
#func get_possible_payment():
	#return []
#
### Pays for the costs. Activates the cards effect. Also discards the card from hand
#func cast(payment: EnergyStack = null) -> void:
	#casting_effect()
#
### The current costs with all the modifiers if there are any
#func get_costs() -> EnergyStack:
	#return []
#
### This is for overriding if there are general cast-conditions
#func is_unlocked() -> bool:
	#return true
#
### This is for overriding if there are conditions for targets
#func is_current_cast_valid() -> bool:
	#return true
#
### Most important function for overwriting. Here should be the effect
#func casting_effect() -> void:
	#pass

## For overriding to give the event length (Could be also moved to SpellRes)
func get_event_length() -> int:
	return 0

func initialize_event() -> void:
	spell.round_persistant_properties["event_current_round"] = 0

## Processes the next round of the event. Returns true if the event is done
func advance_event() -> bool:
	spell.round_persistant_properties["event_current_round"] += 1
	
	var round_number : int = spell.round_persistant_properties["event_current_round"]
	var event_name := spell.type.pretty_name
	var effect_text := spell.type.effect_text
	combat.animation.callback(combat.ui, "set_status", ["Event %s (Round %s)\n%s" % [event_name, round_number, effect_text] ])
	
	event_effect(round_number)
	if spell.round_persistant_properties["event_current_round"] >= get_event_length():
		finalize_event()
		return true
	return false

## Most important function for overwriting. Here should be the event effect
func event_effect(round_number: int) -> void:
	pass

func finalize_event() -> void:
	spell.round_persistant_properties.erase("event_current_round")
