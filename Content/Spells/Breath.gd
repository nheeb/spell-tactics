extends SpellLogic

func execute() -> void:
	combat.cards.draw()
	combat.castables.get_active_from_name("Drain").add_to_bonus_uses(1)

func is_selectable() -> bool:
	return is_castable()

func is_castable() -> bool:
	for tile in combat.player.current_tile.get_surrounding_tiles(
		data.get("no_enemies_range", 1)):
			for e in tile.entities:
				if e is Entity:
					if e.team == EntityType.Teams.Evil:
						return false
	return true
