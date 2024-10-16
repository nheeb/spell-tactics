class_name TimedEffectsUtility extends CombatUtility

## All the timed Effects. This array gets serialized
var effects : Array[TimedEffect]

## Dictionary Signal -> Array of TimedEffects ordered by prio
var connected_effects : Dictionary

func connect_all_effects() -> void:
	for te in effects:
		if (not te.effect_connected) and (not te.dead):
			connect_effect(te)

func connect_effect(te: TimedEffect) -> void:
	te._connect_with_combat(combat)
	if te.connected_signal in connected_effects:
		var array_of_effects = connected_effects[te.connected_signal] as Array
		assert(array_of_effects is Array)
		array_of_effects.append(te)
		array_of_effects.sort_custom(func(a,b) : \
			return a.priority > b.priority if a.priority != b.priority else a.call_method <= b.call_method)
	else:
		connected_effects[te.connected_signal] = [te]
		te.connected_signal.connect(signal_triggered.bind(te.connected_signal))

func get_effects(effect_owner: Object, id := "") -> Array[TimedEffect]:
	var _effects : Array[TimedEffect] = []
	for te in effects:
		if te == null:
			push_warning("How did a null value get into the t_effects?")
			continue
		if te.get_owner() == effect_owner and (id == "" or id == te.get_id()):
			_effects.append(te)
	return _effects

## To be clean use TimedEffect.register(combat) instead
func add_effect(te: TimedEffect) -> void:
	effects.append(te)
	connect_effect(te)

## Since cringe Godot doen't allow vararg we do it that way ...
func signal_triggered(sig_param0 = null, sig_param1 = null, sig_param2 = null, \
					 sig_param3 = null, sig_param4 = null, sig_param5 = null):
	var sig: Signal
	var sig_params := []
	# Since Godot is omega cringe we need to search for the signal manually
	# because binded args come after the signal args.
	for param in [sig_param0, sig_param1, sig_param2, sig_param3, sig_param4, sig_param5]:
		if param != null:
			if param is Signal:
				if not sig.is_null():
					push_error("Timed effect signal has a signal in its parameters")
				sig = param
			else:
				sig_params.append(param)

	if sig not in connected_effects.keys():
		push_error("TE Signal triggered but it's not connected to an effect.")
		return

	# Get all TE connected to that signal
	var signal_effects : Array = connected_effects[sig]
	for te in signal_effects.duplicate():
		te = te as TimedEffect
		# Test if TE is still active and connected with all its references
		# Otherwise it gets deleted
		if te._validate():
			# Test if all the TE 's conditions are met. (Just optional flavor right now)
			var te_wants_trigger := true
			if te.has_flag(TimedEffect.Flags.FlavorMatchMandatory):
				if not te.needed_flavor.fits_into(
					combat.action_stack.active_ticket.get_flavor()
				):
					te_wants_trigger = false
			if te_wants_trigger:
				# Trigger the TE
				var te_callable : Callable = te._trigger.bind(sig_params)
				if te.has_flag(TimedEffect.Flags.TriggerAfterActiveTicket):
					combat.action_stack.push_behind_active(te_callable)
				else:
					# Pushing TE as action before the active.
					# This is NOT TRIGGERING THEM DIRECTLY. Use wait() to do so.
					combat.action_stack.push_before_active(te_callable)
		else:
			signal_effects.erase(te)

	if signal_effects.is_empty():
		connected_effects.erase(sig)
		sig.disconnect(signal_triggered.bind(sig))
