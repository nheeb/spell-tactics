class_name StartPhase extends CombatPhase

## Start phase -> Drawing hand cards
func process_phase() -> void:
	combat.animation.call_method(combat.ui, "set_status", ["Drawing hand cards..."])
	combat.animation.wait(.5)
	combat.cards.draw()
	
	#combat.log.add("Enemies plan their moves...",)
	#for enemy in combat.get_all_enemies():
		#combat.action_stack.push_back(enemy.plan_next_action)
	#await combat.action_stack.wait()
	
	if Game.DEBUG_SPELL_TESTING:
		combat.energy.gain(Game.testing_energy, combat.player)
	
	combat.log.add("Saving game...",)
	await combat.action_stack.process_callable(auto_save)

func auto_save():
	if combat.current_round == 1:
		return
	var overworld: Overworld = null
	
	for activity in ActivityManager.activity_stack:
		if activity is OverworldActivity:
			overworld = activity.overworld
	
	if not overworld:
		push_error("No Overworld found for auto-saving")
		return
	
	var combat_state := combat.serialize()
	var thread = Thread.new()
	thread.start(func():
		await VisualTime.new_timer(.5).timeout
		combat_state.generate_meta("Auto Save - Round %s" % combat.current_round)
		SaveFile.save_to_disk(combat_state, Game.SAVE_DIR + combat_state.meta.filename + ".tres")
		)
	thread.wait_to_finish()
	
