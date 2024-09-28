class_name CastableLogic extends Object

var combat: Combat
var target # Tile
var targets: Array[Tile]
var target_entities: Array[Entity]:
	get:
		if target is Tile:
			return target.entities
		return []
var target_enemies: Array[EnemyEntity]:
	get:
		if target is Tile:
			return target.get_enemies()
		return []
var target_enemy: EnemyEntity:
	get:
		return Utility.array_safe_get(target_enemies, 0)

func is_selectable() -> bool:
	return _is_selectable()

func is_castable() -> bool:
	return _is_castable()

var cast_success := true

func try_cast() -> void:
	update_selected_target_references()
	cast_success = true
	before_cast()
	await casting_effect()
	after_cast()

func update_selected_target_references():
	targets = get_castable().targets
	if not targets.is_empty():
		target = targets[0]
	else:
		target = null

func mark_cast_failed() -> void:
	cast_success = false

func was_cast_successful() -> bool:
	return cast_success

## This is for easy use of TimedEffects and callables
func get_reference() -> PropertyReference:
	return PropertyReference.new(get_castable().get_reference(), "logic")

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

func _set_preview_visuals(show: bool, _target: Tile, clicked: bool = false) -> void:
	pass

func _on_combat_game_change() -> void:
	pass
