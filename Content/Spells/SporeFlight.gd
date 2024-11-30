extends SpellLogic

func execute() -> void:
	combat.animation.effect(VFX.BILLBOARD_EFFECT, target_tile, {"grow_size": 2.0, "texture_name": "poison_cloud"})
	var enemies : Array[EnemyEntity] = []
	for tile in target_tile.get_surrounding_tiles():
		tile = tile as Tile
		enemies.append_array(tile.get_enemies())
	for e in enemies:
		combat.animation.say(e.visual_entity,"Poisoned",{"color": Color.VIOLET}).set_duration(.2)
		e.apply_status(Preloaded.STATUS_POISON)
