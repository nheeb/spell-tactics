class_name SpellPhase extends AbstractPhase

#enum CastingState {
	#Selecting,
	#SettingEnergy,
	#Targeting,
	#Casting
#}

#signal changed_casting_state(s: CastingState)
#var state: CastingState = CastingState.Selecting:
	#set(s):
		#if state != s:
			#state = s
			#changed_casting_state.emit(s)
#var selected_spell: Spell
var highlighted_targets: Array[Tile]

func _ready() -> void:
	pass


#func return_to_spell_selection():
	#state = CastingState.Selecting
	#combat.level._unhighlight_tile_set(highlighted_targets, Highlight.Type.Combat)
	#combat.animation.callback(combat.ui, "set_status", ["Drain tiles and Cast your spells!"])
	#combat.animation.play_animation_queue()
	#selected_spell = null
	#set_process(false)
	#combat.ui.deselect_card()

#func tile_clicked(tile: Tile):
	## TODO Nitai remove this method completely
	#return
	## for now try draining anytime a tile is clicked. later we'll need state,
	## whether we're targeting a spell or draining
	#if state == CastingState.Selecting:
		#combat.input.process_action(PlayerDrain.new(tile))
	#elif state == CastingState.Targeting:
		## try casting the spell onto the selected tile
		## TODO support targetted spells with X/Any type Energy
		## for now read the cost out of the spell (hack)
		#var target = tile
		#match selected_spell.type.target:
			#SpellType.Target.Cone:
				#target = highlighted_targets
		#
		#var payment = combat.ui.extract_payment()  # for now: reading payment from text input
		#var valid: bool = combat.input.process_action(PlayerCastTargeted.new(selected_spell, payment, target))
		#if valid:
			#return_to_spell_selection()

#func tile_hovered(tile: Tile):
	#if state == CastingState.Targeting:
		#if selected_spell.type.target == SpellType.Target.Cone:
			#combat.level._unhighlight_tile_set(highlighted_targets, Highlight.Type.Combat)
			#highlighted_targets = combat.level.get_cone_tiles(\
					#combat.player.current_tile, tile, selected_spell.type.target_min_range,\
							#selected_spell.type.target_range, 1)
			#combat.level._highlight_tile_set(highlighted_targets, Highlight.Type.Combat)

func process_phase() -> bool:
	# reset MovementPhase specific UI
	combat.level._unhighlight_tile_set(combat.level.get_all_tiles(), Highlight.Type.Movement)
	combat.level.immediate_arrows().clear()
	combat.get_phase_node(Combat.RoundPhase.Movement).highlight_payable_spells(null)
	combat.get_phase_node(Combat.RoundPhase.Movement).highlight_for_spell_energy(null)
	
	#state = CastingState.Selecting  # reset state
	combat.animation.callback(combat.ui, "set_status", ["Drain tiles and Cast your spells!"])
	
	# unlock all actives that are available once per round
	for active in combat.actives:
		if active.is_limited_per_round():
			active.refresh_uses_left()
	
	return true


#func select_spell(spell: Spell):
	#if state == CastingState.Targeting:
		## already targeting another spell, need to unhighlight here
		#combat.level._unhighlight_tile_set(highlighted_targets, Highlight.Type.Combat)
	#assert(combat.current_phase == combat.RoundPhase.Spell, "selected a spell outside of spell phase")
	#selected_spell = spell
	#if spell.type.target != SpellType.Target.None:
		#highlighted_targets = get_spell_targets(selected_spell)
		#
		#if len(highlighted_targets) == 0 and spell.type.target != SpellType.Target.Cone:
			#combat.animation.callback(combat.ui, "set_status", ["No targets available."])
			#combat.animation.wait(1.0)
			#combat.animation.callback(combat.ui, "set_status", ["Drain tiles and Cast your spells!"])
			#return
#
		#combat.animation.callback(combat.ui, "set_status", ["Choose the target!\n(Right-click to deselect)"])
		#combat.animation.callback(combat.player.visual_entity, "start_casting")
		#combat.level._highlight_tile_set(highlighted_targets, Highlight.Type.Combat)
		#set_process(true)
		#state = CastingState.Targeting
	#else:
		## else proceed to energy / casting
		#combat.animation.callback(combat.player.visual_entity, "start_casting")
		#state = CastingState.SettingEnergy
#
#func deselect_spell():
	#assert(is_instance_valid(selected_spell))
	#return_to_spell_selection()

#func get_spell_targets(spell: Spell) -> Array[Tile]:
	#var target_range = spell.type.target_range
	#var target_min_range = spell.type.target_min_range
	#var tiles: Array[Tile]
	#if target_range != -1:
		#tiles = combat.level.get_all_tiles_in_distance_of_tile(combat.player.current_tile, 
															   #target_range)
	#else:
		#tiles = combat.level.get_all_tiles()
	#
	#if target_min_range != -1:
		#var min_range_tiles = combat.level.get_all_tiles_with_min_distance_of_tile(combat.player.current_tile, target_min_range)
		#tiles = tiles.filter(func (t): return t in min_range_tiles)
	#
	## for now just Spells targeted on Enemy, 
	## later we have to check the target type in SpellType
	#if spell.type.target == SpellType.Target.Enemy:
		#tiles = tiles.filter(func(t): return t.has_enemy())
	#elif spell.type.target == SpellType.Target.TileWithoutObstacles:
		#tiles = tiles.filter(func(t): return not(t.get_obstacle_layers() & EntityType.NAV_OBSTACLE_LAYER))
	#elif spell.type.target == SpellType.Target.Tag:
		#tiles = tiles.filter(func(t): return spell.type.target_tag in t.get_tags())
	#elif spell.type.target == SpellType.Target.Cone:
		#var none : Array[Tile] = []
		#return none
	#return tiles 


#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("deselect"):
		#combat.input.process_action(DeselectSpell.new())
