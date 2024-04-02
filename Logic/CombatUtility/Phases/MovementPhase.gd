class_name MovementPhase extends AbstractPhase

var highlighted_tiles: Array[Tile]

func tile_hovered(tile: Tile):
	var path = combat.level.get_shortest_path(combat.player.current_tile, tile)
	if len(path) > 0 and not combat.animation.is_playing():
		var positions : Array[Vector3] = [combat.player.current_tile.global_position]
		for t in path:
			positions.append(t.global_position)
		combat.level.immediate_arrows().render_path(positions)
		highlight_payable_spells(tile)
	
func tile_clicked(tile: Tile):
	# state gets reset in process_phase() in SpellPhase
	combat.input.process_action(PlayerMovement.new(tile))

func process_phase() -> bool:
	combat.animation.callback(combat.level, "highlight_movement_range", [combat.player, combat.player.traits.movement_range])
	combat.animation.callback(combat.ui, "set_status", ["Make your movement!"])
	
	return true

func card_hovered(card: HandCard3D):
	if card:
		var spell := card.card_2d.spell as Spell
		if not combat.animation.is_playing():
			highlight_for_spell_energy(spell.get_costs())
	else:
		highlight_for_spell_energy(null)

func highlight_for_spell_energy(energy: EnergyStack):
	highlight_payable_spells(null)
	for tile in combat.level.get_all_tiles():
		if energy:
			@warning_ignore("shadowed_global_identifier")
			var range := combat.player.traits.movement_range
			tile.set_highlight(Highlight.Type.HighSpellEnergy, \
				tile.get_drainable_energy_in_range(1).can_pay_costs(energy) \
				and (not tile.is_blocked() ) \
				and tile.distance_to(combat.player.current_tile) <= range )
			tile.set_highlight(Highlight.Type.LowSpellEnergy, \
				tile.get_drainable_energy().shares_type_with(energy))
		else:
			tile.set_highlight(Highlight.Type.HighSpellEnergy, false)
			tile.set_highlight(Highlight.Type.LowSpellEnergy, false)

func highlight_payable_spells(tile: Tile):
	for spell in combat.hand:
		if tile and (not tile.is_blocked()):
			spell.visual_representation.set_payable_hint( \
				tile.get_drainable_energy_in_range(1).can_pay_costs(spell.get_costs()))
		else:
			spell.visual_representation.set_payable_hint(false)

