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
	print("spellphase tile clicked")
	if state == CastingState.Selecting:
		combat.input.process_action(PlayerDrain.new(tile))
	elif state == CastingState.Targeting:
		# try casting the spell onto the selected tile
		# TODO support targetted spells with X/Any type Energy
		# for now read the cost out of the spell (hack)
		var payment = combat.ui.extract_payment()  # for now: reading payment from text input
		var valid: bool = combat.input.process_action(PlayerCastTargeted.new(selected_spell, payment, tile))
		if valid:
			state = CastingState.Selecting
			combat.level._unhighlight_tile_set(highlighted_targets, Highlight.Type.Combat)
			combat.animation.callback(combat.ui, "set_status", ["Drain tiles and Cast your spells!"])
			combat.animation.play_animation_queue()
		# should something happen here if it doesn't work?

func process_phase() -> bool:
	state = CastingState.Selecting  # reset state
	combat.animation.callback(combat.ui, "set_status", ["Drain tiles and Cast your spells!"])
	
	# unlock all actives that are available once per round
	for active in combat.actives:
		if active.type.limitation == ActiveType.Limitation.X_PER_ROUND:
			active.unlocked = true
			active.uses_left = max(active.uses_left, active.type.max_uses_per_round)
		# check active unlocked conditions
	
	return true
	

func select_spell(spell: Spell):
	if state == CastingState.Targeting:
		# already targeting another spell, need to unhighlight here
		combat.level._unhighlight_tile_set(highlighted_targets, Highlight.Type.Combat)
	assert(combat.current_phase == combat.RoundPhase.Spell, "selected a spell outside of spell phase")
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
	var target_min_range = spell.type.target_min_range
	var tiles: Array[Tile]
	if target_range != -1:
		tiles = combat.level.get_all_tiles_in_distance_of_tile(combat.player.current_tile, 
															   target_range)
	else:
		tiles = combat.level.get_all_tiles()
	
	if target_min_range != -1:
		var min_range_tiles = combat.level.get_all_tiles_with_min_distance_of_tile(combat.player.current_tile, target_min_range)
		tiles = tiles.filter(func (t): return t in min_range_tiles)
	
	# for now just Spells targeted on Enemy, 
	# later we have to check the target type in SpellType
	if spell.type.target == SpellType.Target.Enemy:
		tiles = tiles.filter(func(t): return t.has_enemy())
	elif spell.type.target == SpellType.Target.TileWithoutObstacles:
		tiles = tiles.filter(func(t): return not(t.get_obstacle_layers() & EntityType.NAV_OBSTACLE_LAYER))
	elif spell.type.target == SpellType.Target.Tag:
		tiles = tiles.filter(func(t): return spell.type.target_tag in t.get_tags())
	return tiles 


#func _on_input_utility_performed_action(action: PlayerAction) -> void:
	#if action is SelectSpell:
		#if state == CastingState.Selecting:
			## TODO if spell is targetable
			#selected_spell = action.selected_spell
			#pass