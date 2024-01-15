extends SpellLogic

### The current costs with all the modifiers if there are any
#func get_costs() -> Array[Game.Energy]:
	#return spell.type.costs

## This is for overriding if there are general cast-conditions
#func is_unlocked() -> bool:
	#return true

## This is for overriding if there are conditions for targets
#func is_current_cast_valid() -> bool:
	#return true

## Most important function for overwriting. Here should be the effect
func casting_effect() -> void:
	combat.ui_utility.set_debug_status("Doing nothing...")
	combat.animation_queue.append(AnimationWait.new(1.2))
	combat.ui_utility.set_debug_status("Nothing was done.")

