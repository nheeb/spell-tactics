class_name TimedEffect extends Resource

@export var signal_ref: UniversalReference
@export var signal_name: String
@export var call_ref: UniversalReference
@export var call_method: String
@export var call_params: Array
@export var owner_ref: UniversalReference
@export var death_ref: UniversalReference
@export var death_method: String
@export var death_params: Array
@export var priority: int = 0
## For naming custom timed effects to access them later
@export var id : String

var effect_connected := false
var signal_obj: Object
var call_obj: Object
var owner_obj: Object
var connected_signal: Signal
var connected_method: Callable
var death_obj: Object
var connected_death_method: Callable

enum Flags {
	LimitedTriggers = 1,
	DontDisconnectWhenInGraveyard = 2,
	AppendSignalParamsToCall = 4,
	AppendSelfReferenceToCall = 8,
	ExtraCallOnDeath = 16,
	ReplaceCallOnDeath = 32,
}

@export var flags: int = 0

@export var triggers_left := 0
@export var delay := 0

@export var trigger_counter := 0
@export var dead := false

func _init(_signal_ref: UniversalReference = null, _signal_name: String = "", \
	_call_ref: UniversalReference = null, _call_method: String = "", _call_params: Array = []) -> void:
	signal_ref = _signal_ref
	signal_name = _signal_name
	call_ref = _call_ref
	call_method = _call_method
	call_params = _call_params

func _connect_with_combat(combat: Combat) -> void:
	effect_connected = true
	signal_obj = signal_ref.resolve(combat)
	if signal_obj:
		if signal_obj.has_signal(signal_name):
			connected_signal = signal_obj.get(signal_name)
		else:
			printerr("Timed Effect: signal object %s has no signal %s" % [signal_obj, signal_name])
	else:
		printerr("Timed Effect: signal reference %s is invalid" % signal_ref)
	call_obj = call_ref.resolve(combat)
	if call_obj:
		if call_obj.has_method(call_method):
			connected_method = call_obj.get(call_method)
		else:
			printerr("Timed Effect: call object %s has no method %s" % [call_obj, call_method])
	else:
		printerr("Timed Effect: call reference %s is invalid" % call_ref)
	if owner_ref:
		owner_obj = owner_ref.resolve(combat)
	else:
		owner_obj = call_obj
	if Utility.has_int_flag(flags, Flags.ExtraCallOnDeath) or Utility.has_int_flag(flags, Flags.ReplaceCallOnDeath):
		if death_ref:
			death_obj = death_ref.resolve(combat)
			if death_obj.has_method(death_method):
				connected_death_method = death_obj.get(death_method)

func set_flag(flag: int, value := true) -> TimedEffect:
	if value:
		flags = Utility.add_int_flag(flags, flag)
	else:
		flags = Utility.remove_int_flag(flags, flag)
	return self

func give_timed_effect_as_parameter() -> TimedEffect:
	return set_flag(Flags.AppendSelfReferenceToCall)

func set_death_callback(replace: bool, ref: UniversalReference, method: String, params := []) -> TimedEffect:
	assert(not effect_connected)
	death_ref = ref
	death_method = method
	death_params = params
	set_flag(Flags.ExtraCallOnDeath, not replace)
	set_flag(Flags.ReplaceCallOnDeath, replace)
	return self

func extra_last_callable(callable: Callable, params := []) -> TimedEffect:
	assert(callable.is_valid() and callable.is_standard())
	assert(callable.get_object().has_method("get_reference"))
	var _ref = callable.get_object().get_reference()
	var _method = callable.get_method()
	return set_death_callback(false, _ref, _method, params)

func replace_last_callable(callable: Callable, params := []) -> TimedEffect:
	assert(callable.is_valid() and callable.is_standard())
	assert(callable.get_object().has_method("get_reference"))
	var _ref = callable.get_object().get_reference()
	var _method = callable.get_method()
	return set_death_callback(true, _ref, _method, params)

func set_trigger_count(trigger_count: int) -> TimedEffect:
	triggers_left = trigger_count
	set_flag(Flags.LimitedTriggers)
	return self

func set_oneshot() -> TimedEffect:
	return set_trigger_count(1)

func set_delay(_delay: int) -> TimedEffect:
	delay = _delay
	return self

func set_priority(prio: int) -> TimedEffect:
	priority = prio
	return self

## Those params will be the first params (those params -> signal_params -> timed_effect_reference)
func set_params(params: Array) -> TimedEffect:
	call_params = params
	return self

func _validate() -> bool:
	if not effect_connected:
		printerr("Not connected TimedEffect tries to validate")
		return false

	if connected_signal.is_null():
		dead = true
	
	if not connected_method.is_valid():
		dead = true
	
	if not Utility.has_int_flag(flags, Flags.DontDisconnectWhenInGraveyard):
		if call_obj:
			if call_obj is Entity:
				if call_obj.is_dead():
					dead = true
			elif call_obj is EntityLogic or call_obj is StatusEffect:
				if call_obj.entity.is_dead():
					dead = true

	return not dead

func _trigger(signal_params := []):
	if delay > 0:
		delay -= 1
		return
	trigger_counter += 1
	if Utility.has_int_flag(flags, Flags.LimitedTriggers):
		triggers_left -= 1
		if triggers_left <= 0:
			dead = true
	if not (Utility.has_int_flag(flags, Flags.ReplaceCallOnDeath) and dead):
		var args := call_params.duplicate()
		if signal_params and Utility.has_int_flag(flags, Flags.AppendSignalParamsToCall):
			args.append_array(signal_params)
		if Utility.has_int_flag(flags, Flags.AppendSelfReferenceToCall):
			args.append_array([self])
		if connected_method.is_valid():
			connected_method.callv(args)
	if dead and (Utility.has_int_flag(flags, Flags.ReplaceCallOnDeath) or Utility.has_int_flag(flags, Flags.ExtraCallOnDeath)):
		connected_death_method.callv(death_params)

func _set_signal(sig: Signal) -> TimedEffect:
	assert(not effect_connected)
	assert(not sig.is_null())
	assert(sig.get_object().has_method("get_reference"))
	signal_ref = sig.get_object().get_reference()
	signal_name = sig.get_name()
	return self

func _set_callable(callable: Callable) -> TimedEffect:
	assert(not effect_connected)
	assert(callable.is_valid() and callable.is_standard())
	assert(callable.get_object().has_method("get_reference"))
	call_ref = callable.get_object().get_reference()
	call_method = callable.get_method()
	return self

func set_owner(ref: UniversalReference) -> TimedEffect:
	owner_ref = ref
	return self

func get_owner() -> Object:
	return owner_obj

func set_id(_id: String) -> TimedEffect:
	id = _id
	return self

func get_id() -> String:
	return id

## This should be the last thing executed on a Timed Effect. No more changes after it was connected
func register(combat: Combat) -> void:
	combat.t_effects.add_effect(self)

static func new_end_phase_trigger_from_callable(callable: Callable) -> TimedEffect:
	var end_phase_ref = CombatNodeReference.new("Phases/EndPhase")
	return TimedEffect.new(end_phase_ref, "process_start")._set_callable(callable)

# TODO Test this
## Only works of the owners of the signal and callable have "get_reference()"
static func new_from_signal_and_callable(sig: Signal, callable: Callable) -> TimedEffect:
	return TimedEffect.new()._set_signal(sig)._set_callable(callable)
