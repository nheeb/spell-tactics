extends SpellLogic

var damage := 3

func execute() -> void:
	assert(target_tiles.size() == 2)
	var source_tile := target_tiles[0]
	var destination_tile := target_tiles[1]
	var ents := source_tile.entities.filter(func(e: Entity): return "summoned" in e.get_tags())
	var enemies := destination_tile.get_enemies()
	for ent in ents:
		combat.movement.blink_entity(ent, destination_tile).set_flag_with()
		for enemy in enemies:
			enemy.inflict_damage_with_visuals(damage)
