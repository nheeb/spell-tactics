class_name Active extends Castable

signal got_locked
signal got_unlocked
signal got_updated

@export var type: ActiveType

var logic: ActiveLogic

## set by the UI. Every Active should have an ActiveButton :)
var button: ActiveButtonWithUses

func serialize() -> ActiveState:
	var state := ActiveState.new(self)
	return state

func get_effect_text() -> String:
	return type.get_effect_text()

var unlocked: bool = false:
	set(u):
		if not u:
			got_locked.emit()
		else:
			got_unlocked.emit()
		unlocked = u
		data["unlocked"] = u

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
	data["uses_left"] = i
	got_updated.emit()
	if i == 0:
		unlocked = false
	else:
		unlocked = true

func set_limitation_max_uses(i: int) -> void:
	data["max_uses"] = i
	got_updated.emit()

func get_limitation_uses_left() -> int:
	return data.get("uses_left", 0)

func get_limitation_max_uses() -> int:
	return data.get("max_uses", type.max_uses_per_round)

func refresh_uses_left() -> void:
	set_limitation_uses_left(get_limitation_max_uses())

func reset_limitation_max_uses() -> void:
	set_limitation_max_uses(type.max_uses_per_round)

func add_to_max_uses(i: int) -> void:
	set_limitation_max_uses(get_limitation_max_uses() + i)
	set_limitation_uses_left(get_limitation_uses_left() + i)
