class_name CombatObject extends RefCounted

## Every combat-connected, referencable & serializable element is a CombatObject
## -> Tiles, Entities, Castables, Events

var combat: Combat
var id: CombatID

func get_reference() -> UniversalReference:
	return null

func serialize() -> CombatObjectState:
	return null

func connect_with_combat(_combat: Combat):
	assert(combat == null, "CombatObject was already connected to combat.")
	combat = _combat
