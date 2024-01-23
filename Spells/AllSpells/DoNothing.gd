extends SpellLogic

### The current costs with all the modifiers if there are any
#func get_costs() -> EnergyStack:
	#return spell.type.costs

## This is for overriding if there are general cast-conditions
#func is_unlocked() -> bool:
	#return true

## This is for overriding if there are conditions for targets
#func is_current_cast_valid() -> bool:
	#return true

## Most important function for overwriting. Here should be the effect
func casting_effect() -> void:
	combat.animation.callback(combat.ui, "set_status", ["Doing nothing..."])
	combat.animation.wait(1.2)
	combat.animation.callback(combat.ui, "set_status", ["Nothing was done."])

