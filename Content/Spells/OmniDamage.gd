extends SpellLogic

func execute() -> void:
	for enemy in combat.get_all_enemies():
		enemy.inflict_damage_with_visuals(1000)
