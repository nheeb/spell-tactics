extends AbstractPhase

enum CastingState {
	Selecting,
	SettingEnergy,
	Targeting,
	Casting
}

var state: CastingState = CastingState.Selecting
var selected_spell: Spell

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
		
	# else proceed to energy / casting

func show_spell_targets(spell: Spell):
	#set_status("Select Target")
	pass  # TODO but maybe not here in UI, this is


#func _on_input_utility_performed_action(action: PlayerAction) -> void:
	#if action is SelectSpell:
		#if state == CastingState.Selecting:
			## TODO if spell is targetable
			#selected_spell = action.selected_spell
			#pass
