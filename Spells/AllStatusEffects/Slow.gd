extends EntityStatusLogic

# TODO this should be done with Discussions / Modifiers as well

## Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func _setup_logic() -> void:
	if entity is not PlayerEntity:
		push_error("Berserker is only (and poorly) implemented for the player right now.")
		return
	data["last_movement"] = combat.player.traits.movement_range
	combat.player.traits.movement_range = data.get("slowed_movement", 1)

## Effects on being removed (clean up timed effects)
func _on_remove() -> void:
	combat.player.traits.movement_range = data.get("last_movement", 3)
