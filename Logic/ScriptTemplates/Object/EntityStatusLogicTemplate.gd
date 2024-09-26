extends EntityStatusLogic

## Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func _setup_logic() -> void:
	pass

## Visual changes when status effect enters the game
func _setup_visually() -> void:
	pass

## How does the effect change, when another instance of the same effect get applied
func _extend(other_status: EntityStatus) -> void:
	pass

## Effects on being removed (clean up timed effects)
func _on_remove() -> void:
	pass

## Special actions an enemy with the status could do
func _get_enemy_actions() -> Array[EnemyActionArgs]:
	return []
