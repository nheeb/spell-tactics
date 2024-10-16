extends AbstractPhase

func process_phase() -> void:
	combat.round_ended.emit(combat.current_round)
	
	# Events
	await combat.action_stack.process_ticket(
		ActionTicket.new(combat.events.process_events)
	)
	
	# All stat resets here
	# combat.energy.pay(combat.energy.player_energy)
	
	if combat.enemies.is_empty():
		# TODO Game won
		combat.log.add("Game Won!")
		combat.animation.call_method(combat.ui, "show_victory", ["You won!"])
	
	combat.animation.call_method(combat.ui, "set_status", ["Round ending ..."])
	
	combat.animation.camera_reach(combat.player.visual_entity)
	combat.animation.property(combat.camera, "player_input_enabled", true)
	
	combat.current_round += 1
	combat.action_stack.mark_combat_changed()
	#combat.animation.callable(
		#combat.ui.timeline.jump_to_round.bind(combat.current_round))
