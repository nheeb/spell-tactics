extends SpellLogic

func execute() -> void:
	assert(target is Tile, "AirMissile expecting Tile as target")
	target = target as Tile
	var enemies = target.get_enemies()
	assert(len(enemies) >= 1, "AirMissile expects min 1 enemy on tile")
	
	for enemy in enemies:
		enemy.inflict_damage_with_visuals(2)
