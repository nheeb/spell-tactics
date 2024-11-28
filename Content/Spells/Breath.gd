extends SpellLogic

func execute() -> void:
	combat.cards.draw()
	var drain_active := Utility.array_safe_get(
		combat.actives.filter(
			func (a: Active): return a.type.internal_name == "Drain"
		), 0) as Active
	drain_active.add_to_bonus_uses(1)
	#combat.energy.gain(EnergyStack.string_to_energy("H"), combat.player)

func is_selectable() -> bool:
	for tile in combat.player.current_tile.get_surrounding_tiles():
		for e in tile.entities:
			if e is HPEntity:
				if e.team == HPEntityType.Teams.Evil:
					return false
	return true

func is_castable() -> bool:
	for tile in combat.player.current_tile.get_surrounding_tiles():
		for e in tile.entities:
			if e is HPEntity:
				if e.team == HPEntityType.Teams.Evil:
					return false
	return true
