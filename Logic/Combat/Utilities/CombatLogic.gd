class_name CombatLogic extends RefCounted

var combat: Combat
var combat_object: CombatObject

var data: Dictionary:
	get:
		return combat_object.data
	set (x):
		combat_object.data = x
		push_warning("Do not set this. Just change the elements instead.")

func setup(co: CombatObject):
	connect_with_combat_object(co)
	connect_with_combat(co.combat)

func connect_with_combat_object(co: CombatObject):
	combat_object = co
	co.set("logic", self)

func connect_with_combat(_combat: Combat):
	assert(combat == null, "CombatLogic was already connected to combat.")
	combat = _combat

func get_reference() -> PropertyReference:
	assert(combat_object.get("logic") == self)
	return PropertyReference.new(combat_object.get_reference(), "logic")

## ACTION
func on_birth() -> void:
	pass

## ACTION
func on_load() -> void:
	pass

## ACTION
func on_death() -> void:
	pass
