class_name Active extends Castable

signal got_locked
signal got_unlocked
signal uses_got_updated(uses_left: int, max_uses: int)

@export var type: ActiveType

var logic: ActiveLogic

## set by the UI. Every Active should have an ActiveButton :)
var button: ActiveButtonWithUses

func serialize() -> ActiveState:
	var state := ActiveState.new(self)
	return state

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
## We use the data dict to save everything related   ##
#######################################################

## ANIMATION
func update_uses_visually(uses_left: int, max_uses: int):
	uses_got_updated.emit(uses_left, max_uses)

func is_limited_per_round() -> bool:
	return type.limitation == ActiveType.Limitation.X_PER_ROUND

func add_to_uses_left(i: int) -> void:
	if i < 0:
		var bonus := data.get("bonus_uses", 0) as int
		if bonus > 0:
			var diff = min(bonus, -i)
			add_to_bonus_uses(-diff)
			i += diff
	set_limitation_uses_left(get_limitation_uses_left() + i)

func set_limitation_uses_left(i: int) -> void:
	i = max(0, i)
	data["uses_left"] = i
	combat.animation.callable(update_uses_visually.bind(
		get_limitation_uses_left(), get_limitation_max_uses()
	))
	if i == 0:
		unlocked = false
	else:
		unlocked = true

func set_limitation_max_uses(i: int) -> void:
	data["max_uses"] = i
	combat.animation.callable(update_uses_visually.bind(
		get_limitation_uses_left(), get_limitation_max_uses()
	))

func get_limitation_uses_left() -> int:
	var left := data.get("uses_left", 0) as int
	return left

func get_limitation_max_uses() -> int:
	return data.get("max_uses", type.max_uses_per_round)

func refresh_uses_left() -> void:
	set_limitation_uses_left(get_limitation_max_uses())

func reset_limitation_max_uses() -> void:
	set_limitation_max_uses(type.max_uses_per_round)

func add_to_max_uses(i: int) -> void:
	set_limitation_max_uses(get_limitation_max_uses() + i)
	set_limitation_uses_left(get_limitation_uses_left() + i)

func add_to_bonus_uses(i: int) -> void:
	var bonus := data.get("bonus_uses", 0) as int
	bonus += i
	data["bonus_uses"] = bonus
	add_to_max_uses(i)
	if i > 0:
		combat.animation.effect(VFX.HEX_RINGS, combat.player, \
			{"color": Color.YELLOW}).set_duration(.6)
		combat.animation.say(combat.player, "+%s %s" % [i, type.pretty_name]) \
			.set_flag_with()
