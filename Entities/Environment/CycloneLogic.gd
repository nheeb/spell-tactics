extends EntityLogic

var duration = 3

@export var damage := 2

func on_create():
	TimedEffect.new_end_phase_trigger_from_callable(make_damage).set_trigger_count(duration)\
			.extra_last_callable(entity.die).register(combat)

func on_graveyard():
	pass

func make_damage():
	var tile: Tile = entity.current_tile
	assert(tile)
	var anims = []
	var enemies = tile.get_enemies()
	for enemy in enemies:
		anims.append(enemy.inflict_damage_with_visuals(damage))
	if combat.player.current_tile == tile:
		anims.append(combat.player.inflict_damage_with_visuals(damage))
	if anims:
		anims.push_front(combat.animation.say(tile, "Cyclone Damage").set_delay(.5))
		anims.push_front(combat.animation.camera_reach(tile))
		combat.animation.reappend_as_array(anims)
		
