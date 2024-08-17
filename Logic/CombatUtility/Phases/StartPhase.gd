extends AbstractPhase

## Start phase -> Drawing hand cards
func process_phase() -> bool:
	combat.animation.callback(combat.ui, "set_status", ["Drawing hand cards..."])
	combat.animation.wait(.5)
	combat.cards.draw_to_hand_size()
	
	for enemy in combat.get_all_enemies():
		enemy.plan_next_action()
	
	if Game.DEBUG_SPELL_TESTING:
		combat.energy.gain(Game.testing_energy)
	
	auto_save()
	
	return false

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
	
	var state = overworld.serialize(combat.serialize())
	var thread = Thread.new()
	thread.start(func():
		await VisualTime.new_timer(1).timeout
		state.generate_meta("Auto Save - Round %s" % combat.current_round)
		SaveFile.save_to_disk(state, Game.SAVE_DIR + state.meta.filename + ".tres")
		)
	thread.wait_to_finish()
	
