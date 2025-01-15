class_name PlayerAction extends RefCounted
## Every input the player does will be processed by creating and resolving the
## corresponding PlayerAction Object.
## INFO Not all processed PlayerAction Objects are directly created by the player.
## Some PlayerActions cause others to trigger.
## (e.g. Select Castable -> Auto Load Energy -> Load Energy)

# TBD Not sure if we need those signals
signal executed
signal failed

## Readable representation for debuging. This should be set in the constructor.
var action_string := "Undefined"

## List of all types that would block the PlayerAction.
## This should be set in the constructor.
var blocking_types: Array[InputUtility.InputBlockType]

## Tells if the PlayerAction might change the game state.
## This should be set in the constructor.
var changes_combat := false

func _to_string() -> String:
	return "PA:%s" % action_string

############################
## Methods for overriding ##
############################

## Tests if the Action is valid right now given that it didn't get blocked
func is_valid(combat: Combat) -> bool:
	return true

## ACTION
## The Action part of the PlayerAction
func execute(combat: Combat) -> void:
	pass

## ACTION
## Optional Action in case the PA wasn't valid.
## TBD Should this be called when the PA was blocked as well?
func on_fail(combat: Combat) -> void:
	pass

###################
## Customization ##
###################

var _forced := false

## Forced PlayerAction will not get blocked. However they still test if valid.
func force_execution() -> PlayerAction:
	_forced = true
	return self
