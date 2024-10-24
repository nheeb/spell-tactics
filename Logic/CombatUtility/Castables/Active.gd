class_name Active extends Castable

signal got_locked
signal got_unlocked
signal got_updated

var type: ActiveType
var id: ActiveID = null

var logic: ActiveLogic

## set by the UI. Every Active should have an ActiveButton :)
var button: ActiveButtonWithUses

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

func is_selectable() -> bool:
	return unlocked and logic.is_selectable()

func select():
	combat.animation.callable(combat.ui.cards3d.add_active_to_pin.bind(self))
	super.select()

func deselect():
	super.deselect()
	if combat.ui.cards3d.pinned_card: 
		if combat.ui.cards3d.pinned_card.get_castable() == self:
			combat.animation.callable(combat.ui.cards3d.unpin_card)
		else:
			push_error("Tried to deselect active which wasnt pinned")
	else:
		push_error("Tried to deselect active which wasnt pinned")

var card: ActiveCard
func get_card() -> Card3D:
	return card

func get_logic() -> CastableLogic:
	return logic

func get_type() -> CastableType:
	return type

func get_button_caption() -> String:
	if is_limited_per_round():
		return "%s (%s / %s)" % [type.pretty_name, get_limitation_uses_left(), \
													get_limitation_max_uses()]
	else:
		return type.pretty_name

#######################################################
## Wrappers for (most common) X per round limitation ##
## We have to use round_pers_props for serialization ##
#######################################################

func is_limited_per_round() -> bool:
	return type.limitation == ActiveType.Limitation.X_PER_ROUND

func set_limitation_uses_left(i: int) -> void:
	i = max(0, i)
	round_persistant_properties["uses_left"] = i
	got_updated.emit()
	if i == 0:
		unlocked = false
	else:
		unlocked = true

func set_limitation_max_uses(i: int) -> void:
	round_persistant_properties["max_uses"] = i
	got_updated.emit()

func get_limitation_uses_left() -> int:
	return round_persistant_properties.get("uses_left", 0)

func get_limitation_max_uses() -> int:
	return round_persistant_properties.get("max_uses", type.max_uses_per_round)

func refresh_uses_left() -> void:
	set_limitation_uses_left(get_limitation_max_uses())

func reset_limitation_max_uses() -> void:
	set_limitation_max_uses(type.max_uses_per_round)

func add_to_max_uses(i: int) -> void:
	set_limitation_max_uses(get_limitation_max_uses() + i)
	set_limitation_uses_left(get_limitation_uses_left() + i)
