class_name ActiveLogic extends Object

var active: Active
var combat: Combat
var target  # Entity or Tile or maybe Array[Tile]

func _init(_active: Active):
	active = _active
	combat = active.combat
	if active.type.logic != self.get_script():
		printerr("Weird creation of SpellLogic Object")

## Returns combination of the other valids. Is being used by PlayerCast to execute the cast
func is_all_valid() -> bool:
	return is_unlocked() and is_current_cast_valid()

## Pays for the costs. Activates the cards effect. Also discards the card from hand
func cast(payment: EnergyStack = null) -> void:
	casting_effect()
	var type = active.type as ActiveType
	if type.limitation == ActiveType.Limitation.X_PER_ROUND:  # if this is a once-per-round active, lock it
		active.uses_left -= 1
		if active.uses_left == 0:
			active.unlocked = false

func is_unlocked() -> bool:
	return _is_unlocked()

## This is for overriding if there are general cast-conditions
func _is_unlocked() -> bool:
	return true

## This is for overriding if there are conditions for targets
func is_current_cast_valid() -> bool:
	return true

## Most important function for overwriting. Here should be the effect
func casting_effect() -> void:
	pass


