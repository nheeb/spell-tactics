class_name CombatLogic extends RefCounted

var combat: Combat:
	set(x):
		combat = x
		if combat:
			TimedEffect.new_combat_state_change(_on_combat_game_change)\
				.force_freshness().register(combat)

func _on_combat_game_change() -> void:
	pass
