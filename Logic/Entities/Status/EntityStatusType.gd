class_name EntityStatusType extends CombatObjectType

@export_multiline var text: String = ""

@export_group("Lifetime")
## This will add the value '_lifetime' to the data.
## Lifetime decreases by 1 each End Phase. 
## When it reaches 0 the status will be removed.
@export var has_lifetime := false
@export var lifetime_default := 1
## What happens with lifetime when the status is extended [br]
## [b] max [/b] Take the bigger lifetime [br]
## [b] sum [/b] Add the new lifetime [br]
## [b] reset [/b] Take the new lifetime [br]
## [b] ignore [/b] Take the old lifetime
@export_enum(
	"max:0", "sum:1", "reset:2", "ignore:3"
	) var lifetime_extend_method: int = 0

@export_group("Visuals")
@export var make_floating_icon: bool = true

@export_group("Extras")
## New status of this type will always be merged ("extend") into an existing one if possible.
@export var merge_this_type := false
## Kills all TimedEffects (from status & logic) automatically when being removed.
@export var kill_te_on_remove := true
@export var enemy_actions: Array[EnemyActionArgs]

func create_base_object() -> CombatObject:
	return EntityStatus.new()

func create_status(combat: Combat, _data := {}) -> EntityStatus:
	var status = create(combat, {"data": _data}) as EntityStatus
	return status
