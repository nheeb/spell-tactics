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
		if id == "":
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
	for param in [sig_param0, sig_param1, sig_param2, sig_param3, sig_param4, sig_param5]:
		if param != null:
			if param is Signal:
				if not sig.is_null():
					push_error("Timed effect signal has a signal in its parameters")
				sig = param
			else:
				sig_params.append(param)

	if sig not in connected_effects.keys():
		return

	var signal_effects : Array = connected_effects[sig]
	for te in signal_effects.duplicate():
		te = te as TimedEffect
		if te._validate():
			te._trigger(sig_params)
		else:
			signal_effects.erase(te)

	if signal_effects.is_empty():
		connected_effects.erase(sig)
