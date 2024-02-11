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
	var enemies = tile.get_enemies()
	for enemy in enemies:
		enemy.inflict_damage_with_visuals(damage)
	if combat.player.current_tile == tile:
		combat.player.inflict_damage_with_visuals(damage)
