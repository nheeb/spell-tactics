extends EntityStatusLogic

## Logic when status enters the game.
## This will only be called when the status is applied, not when it is loaded.
func _setup_logic() -> void:
	pass

## Visual changes when status enters the game
func _setup_visually() -> void:
	pass

## Change of status when another instance of the same status get applied
func _extend(other_status: EntityStatus) -> void:
	pass

## Effects on being removed (timed effects get removed by default)
func _on_remove() -> void:
	pass

## Special actions an enemy with the status could do.
func _get_enemy_actions() -> Array[EnemyActionArgs]:
	return []
