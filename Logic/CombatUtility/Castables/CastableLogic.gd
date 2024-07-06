class_name CastableLogic extends Object

var combat: Combat
var target # Tile
var targets: Array[Tile]

func is_selectable() -> bool:
	return _is_selectable()

func is_castable() -> bool:
	return _is_castable()

var cast_success := true

func try_cast() -> void:
	update_targets()
	cast_success = true
	before_cast()
	casting_effect()
	after_cast()

func update_targets():
	targets = get_castable().targets
	if not targets.is_empty():
		target = targets[0]
	else:
		target = null

func mark_cast_failed() -> void:
	cast_success = false

func was_cast_successful() -> bool:
	return cast_success

################################################
## For overriding in SpellLogic & ActiveLogic ##
################################################

func before_cast() -> void:
	pass

func after_cast() -> void:
	combat.input.deselect_castable(get_castable())

func get_castable() -> Castable:
	return null

#####################################
## For overriding in each Castable ##
#####################################

func casting_effect():
	pass

func _is_selectable() -> bool:
	return true

func _is_castable() -> bool:
	return true

func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	return true

func _on_select_deselect(select: bool) -> void:
	pass

func _are_targets_full(_targets: Array[Tile]) -> bool:
	return true

func _are_targets_castable(_targets: Array[Tile]) -> bool:
	return true

func _set_preview_visuals(_target: Tile, active: bool) -> void:
	pass
