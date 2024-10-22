class_name CombatLogic extends RefCounted

# TODO make it work for logics created dynamically during the game.

var combat: Combat:
	set(_combat):
		if _combat:
			combat = _combat
			combat.action_stack.push_front(_on_combat_connect)

## ACTION
func _on_combat_connect() -> void:
	TimedEffect.new_combat_change(_on_combat_change)\
		.force_freshness().set_id("_cs").set_solo().register(combat)

## TE
func _on_combat_change() -> void:
	pass
