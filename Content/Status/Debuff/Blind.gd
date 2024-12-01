extends EntityStatusLogic

## Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func on_birth() -> void:
	if entity is EnemyEntity:
		entity.accuracy -= data.get("acc_malus", 0)

## Effects on being removed (clean up timed effects)
func _on_remove() -> void:
	if entity is EnemyEntity:
		entity.accuracy += data.get("acc_malus", 0)
