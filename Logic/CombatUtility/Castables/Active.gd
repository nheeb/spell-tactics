class_name Active extends Castable

signal got_locked
signal got_unlocked

var type: ActiveType
var id: ActiveID

var logic: ActiveLogic

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

func is_selectable() -> bool:
	return unlocked and logic.is_selectable()

func select():
	combat.ui.cards3d.add_active_to_pin(self)

func deselect():
	if combat.ui.cards3d.pinned_card: 
		if combat.ui.cards3d.pinned_card.get_castable() == self:
			combat.ui.cards3d.unpin_card()
		else:
			printerr("Tried to deselect active which wasnt pinned")
	else:
		printerr("Tried to deselect active which wasnt pinned")

var card: ActiveCard
func get_card() -> Card3D:
	return card
