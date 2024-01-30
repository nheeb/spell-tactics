class_name SpellPhase extends AbstractPhase

enum CastingState {
	Selecting,
	SettingEnergy,
	Targeting,
	Casting
}

signal changed_casting_state(s: CastingState)
var state: CastingState = CastingState.Selecting:
	set(s):
		if state != s:
			state = s
			changed_casting_state.emit(s)
var selected_spell: Spell
var highlighted_targets: Array[Tile]

func _ready() -> void:
	pass


func tile_clicked(tile: Tile):
	# for now try draining anytime a tile is clicked. later we'll need state,
	# whether we're targeting a spell or draining
	if state == CastingState.Selecting:
		combat.input.process_action(PlayerDrain.new(tile))
	elif state == CastingState.Targeting:
		# try casting the spell onto the selected tile
		# TODO support targetted spells with X/Any type Energy
		# for now read the cost out of the spell (hack)
		var valid: bool = combat.input.process_action(PlayerCastTargeted.new(selected_spell, selected_spell.type.costs, tile))
		if valid:
			state = CastingState.Selecting
			combat.level._unhighlight_tile_set(highlighted_targets, Highlight.Type.Combat)
			combat.animation.callback(combat.ui, "set_status", ["Drain tiles and Cast your spells!"])
			combat.animation.play_animation_queue()
		# should something happen here if it doesn't work?

func process_phase() -> bool:
	state = CastingState.Selecting  # reset state
	combat.animation.callback(combat.ui, "set_status", ["Drain tiles and Cast your spells!"])
	return true
	

func select_spell(spell: Spell):
	selected_spell = spell
	if spell.type.target != SpellType.Target.None:
		# wait for player to target
		state = CastingState.Targeting
		combat.animation.callback(combat.ui, "set_status", ["Choose the target!"])
		#combat.animation.callback()
		highlighted_targets = get_spell_targets(selected_spell)
		combat.level._highlight_tile_set(highlighted_targets, Highlight.Type.Combat)
	else:
		# else proceed to energy / casting
		state = CastingState.SettingEnergy

func get_spell_targets(spell: Spell) -> Array[Tile]:
	var target_range = spell.type.target_range  
	var tiles: Array[Tile]
	if target_range != -1:
		tiles = combat.level.get_all_tiles_in_distance_of_tile(combat.player.current_tile, 
															   target_range)
	else:
		tiles = combat.level.get_all_tiles()
	
	# for now just Spells targeted on Enemy, 
	# later we have to check the target type in SpellType
	tiles = tiles.filter(func(t): return t.has_enemy())
	return tiles 


#func _on_input_utility_performed_action(action: PlayerAction) -> void:
	#if action is SelectSpell:
		#if state == CastingState.Selecting:
			## TODO if spell is targetable
			#selected_spell = action.selected_spell
			#pass
