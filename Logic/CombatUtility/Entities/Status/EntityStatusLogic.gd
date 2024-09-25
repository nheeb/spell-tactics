class_name EntityStatusLogic extends RefCounted

var combat: Combat
var entity: Entity
var status: EntityStatus
var type: EntityStatusType:
	get:
		return status.type
var data: Dictionary:
	get:
		return status.data
	set (x):
		push_error("Do not set this. Just change the elements instead.")

############################
## Methods for overriding ##
############################

## Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func _setup_logic() -> void:
	pass

## Visual changes when status effect enters the game
func _setup_visually() -> void:
	pass

## How does the effect change, when the entity would get another instance of the same effect
func _extend(other_status: EntityStatus) -> void:
	pass

## Effects on being removed (clean up timed effects)
func _on_remove() -> void:
	pass

## Special actions an enemy with the status could do
func _get_enemy_actions() -> Array[EnemyActionArgs]:
	return []

####################
## Helper Methods ##
####################

func self_remove() -> void:
	entity.remove_status_effect(status.get_status_name())
