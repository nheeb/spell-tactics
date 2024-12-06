extends EntityStatusLogic

## Logic when status enters the game.
## This will only be called when the status is applied, not when it is loaded.
func on_birth() -> void:
	pass

## Visual changes when status enters the game
func on_load() -> void:
	pass

## Change of status when another instance of the same status get applied
func merge(other_status: EntityStatus) -> void:
	pass

## Effects on being removed (timed effects get removed by default)
func on_death() -> void:
	pass

## Special actions an enemy with the status could do.
func get_enemy_actions() -> Array[EnemyActionArgs]:
	return []
