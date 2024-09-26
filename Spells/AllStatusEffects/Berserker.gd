extends EntityStatusLogic

# TODO Make this cleaner -> Add Action Stack Discussion feature to make abstract modifiers possible

var melee: Active:
	get:
		return combat.castables.get_active_from_name("melee")

## Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func _setup_logic() -> void:
	if entity is not PlayerEntity:
		push_error("Berserker is only (and poorly) implemented for the player right now.")
		return
	melee.logic.modifiers.append(CallableReference.from_callable(berserker_effect))

## Effects on being removed (clean up timed effects)
func _on_remove() -> void:
	melee.logic.modifiers = melee.logic.modifiers.filter(
		func(m: CallableReference):
			return m.get_callable(combat) != berserker_effect
	)

func berserker_effect(dmg: int, _target: EnemyEntity):
	combat.action_stack.push_behind_active(self_remove)
	return dmg * 2
