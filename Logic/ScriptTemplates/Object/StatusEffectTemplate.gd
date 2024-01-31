extends StatusEffect

## Make persistant vars export so they get serialized automatically since StatusEffect is a Resource

## make_timed_effect_self_call(method: String, params := []) -> TimedEffect:
## make_timed_effect_entity_call(method: String, params := []) -> TimedEffect:
## You can use those wrapper functions to create timed effects
## (they get added into the combat automatically and are set on EndPhase by default)
## self_remove() is a shortcut for entity.remove_status_effect(get_status_name())

## Name of the status effect
func get_status_name() -> String:
	return "invalid_status"

## For overwriting: Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func setup_logic() -> void:
	pass

## For overwriting: Visual changes when status effect enters the game
func setup_visually() -> void:
	pass

## For overwriting: How does the effect change, when the entity would get another instance of the same effect
func extend(other_status: StatusEffect) -> void:
	pass

## For overwriting: Effects on being removed
func on_remove() -> void:
	pass
