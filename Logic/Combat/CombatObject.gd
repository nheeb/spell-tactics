class_name CombatObject extends RefCounted
## Every combat-connected, referencable & serializable element is a CombatObject
## -> Tiles, Entities, Castables, Events, EntityStatus

## Reference to the object's combat
var combat: Combat

## Unique ID for that object
@export var id: int = -1
@export var data: Dictionary

var node3d: Node3D
var position: Vector3:
	set(x):
		node3d.position = x
	get:
		return node3d.position
var global_position: Vector3:
	set(x):
		node3d.global_position = x
	get:
		return node3d.global_position

func get_reference() -> UniversalReference:
	return null

func serialize() -> CombatObjectState:
	return null

func connect_with_combat(_combat: Combat):
	assert(combat == null, "CombatObject was already connected to combat.")
	combat = _combat
