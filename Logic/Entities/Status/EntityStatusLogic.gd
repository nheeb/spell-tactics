class_name EntityStatusLogic extends CombatLogic

var status: EntityStatus:
	get:
		return combat_object as EntityStatus
	set(x):
		push_error("Do not set this.")
var entity: Entity:
	get:
		return status.entity
var type: EntityStatusType:
	get:
		return status.type


############################
## Methods for overriding ##
############################

## Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func on_birth() -> void:
	pass

## Visual changes when status effect enters the game
func on_load() -> void:
	pass

## How does the effect change, when the entity would get another instance of the same effect
func merge(other_status: EntityStatus) -> void:
	pass

## Effects on being removed (timed effects are removed by default)
func on_death() -> void:
	pass

## Special actions an enemy with the status could do
func get_enemy_actions() -> Array[EnemyActionArgs]:
	return []

####################
## Helper Methods ##
####################

func self_remove() -> void:
	await combat.action_stack.process_callable(status.die)
