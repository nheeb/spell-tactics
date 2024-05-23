class_name Active extends Object

signal got_locked
signal got_unlocked

var type: ActiveType
var id: ActiveID
var combat: Combat
var logic: ActiveLogic

var combat_persistant_properties := {}
var round_persistant_properties := {}

func _init(_type: ActiveType, _combat : Combat = null) -> void:
	type = _type
	combat = _combat
	if combat != null:
		logic = type.logic.new(self)

func get_copy_for_combat(_combat: Combat) -> Active:
	var active := Active.new(type, _combat)
	active.combat_persistant_properties = combat_persistant_properties.duplicate()
	return active

func serialize() -> ActiveState:
	var state := ActiveState.new()
	state.type = type
	state.id = id
	state.combat_persistant_properties = combat_persistant_properties
	state.round_persistant_properties = round_persistant_properties
	return state
	
func _to_string() -> String:
	return type.internal_name

func get_reference() -> ActiveReference:
	return ActiveReference.new(self)

func get_effect_text() -> String:
	return type.get_effect_text()

var unlocked: bool = false:
	set(u):
		if not u:
			got_locked.emit()
		else:
			got_unlocked.emit()
		unlocked = u
		round_persistant_properties["unlocked"] = u


var uses_left := 0

