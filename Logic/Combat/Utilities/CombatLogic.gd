class_name CombatLogic extends RefCounted

var combat: Combat
var combat_object: CombatObject

func setup(co: CombatObject):
	connect_with_combat_object(co)
	connect_with_combat(co.combat)

func connect_with_combat_object(co: CombatObject):
	combat_object = co
	co.set("logic", self)

func connect_with_combat(_combat: Combat):
	assert(combat == null, "CombatLogic was already connected to combat.")
	combat = _combat
	TimedEffect.new_combat_change(on_combat_change)\
		.force_freshness().set_id("_cc").set_solo().register(combat)

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

## TE
func on_combat_change() -> void:
	pass
