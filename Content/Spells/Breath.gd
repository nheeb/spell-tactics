extends SpellLogic

func execute() -> void:
	combat.castables.get_active_from_name("Drain").add_to_bonus_uses(1)

func is_executable() -> bool:
	return not has_enemy_in_range(data.get("no_enemies_range", 1))

func has_enemy_in_range(dist: int) -> bool:
	for tile in combat.player.current_tile.get_surrounding_tiles(dist):
		for e in tile.entities:
			if e is EnemyEntity and e.team == EntityType.Teams.Evil:
				return true
	return false
