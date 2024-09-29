class_name CombatLogic extends RefCounted

var combat: Combat:
	set(x):
		combat = x
		if combat:
			TimedEffect.new_combat_change(_on_combat_change)\
				.force_freshness().set_id("_cs").set_solo().register(combat)

func _on_combat_change() -> void:
	pass
