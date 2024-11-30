extends SpellLogic

func execute() -> void:
	assert(target is Array)
	combat.animation.wait(.8)
	for tile in target:
		tile = tile as Tile
		var dist = tile.distance_to(combat.player.current_tile)
		combat.animation.effect(VFX.BILLBOARD_EFFECT, tile, {"grow_size": 1.5, \
			 "texture_name": "steam", "duration": 1.2}).set_delay(.2 * dist).set_flag_with()
	
	for tile in target:
		for enemy in tile.get_enemies():
			enemy = enemy as EnemyEntity
			enemy.inflict_damage_with_visuals(1)
			enemy.apply_status(Preloaded.STATUS_WET)
