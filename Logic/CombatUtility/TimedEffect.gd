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
@export var solo := false

## Whether the effect is connected with combat. (Only relevant for deserializing)
var effect_connected := false
var signal_obj: Object
var call_obj: Object
var owner_obj: Object
var connected_signal: Signal
var connected_method: Callable
var death_obj: Object
var connected_death_method: Callable
var broken := false

enum Flags {
	## see set_oneshot() or set_trigger_count()
	LimitedTriggers = 1,
	## on default TE's die when their owner entity dies (= callable owner if not set)
	DontDisconnectWhenInGraveyard = 2,
	## see give_signal_params_as_parameter()
	AppendSignalParamsToCall = 4,
	## see give_timed_effect_as_parameter()
	AppendSelfReferenceToCall = 8,
	ExtraCallOnDeath = 16,
	ReplaceCallOnDeath = 32,
}

@export var flags: int = 0

@export var triggers_left := 0
## If delay is > 0 the next trigger will be ignores and delay will be reduced by 1.
@export var delay := 0
## Counts the triggers
@export var trigger_counter := 0
## Dead effects will be excluded by the TEUtility
@export var dead := false

########################################
## Shortcut methods for easy creation ##
########################################

## If start is true the TE triggers at the start of the end phase (before Events)
## otherwise it triggers at the end.
static func new_end_phase_trigger_from_callable(callable: Callable, start := true) -> TimedEffect:
	var end_phase_ref = CombatNodeReference.new("Phases/EndPhase")
	var process := "process_start" if start else "process_end"
	return TimedEffect.new(end_phase_ref, process)._set_callable(callable)

## Only works of the owners of the signal and callable have "get_reference()"
static func new_from_signal_and_callable(sig: Signal, callable: Callable) -> TimedEffect:
	return TimedEffect.new()._set_signal(sig)._set_callable(callable)

## The callable enters all discussions that fit the flavor.
## The callable must have Discussion as only parameter.
## Do not use set_params on this or any other weird stuff.
static func new_discussion_entry(flavor: ActionFlavor, callable: Callable) \
		-> TimedEffect:
	var action_stack_ref = CombatNodeReference.new("Utility/ActionStackUtility")
	return TimedEffect.new(action_stack_ref, "discussion_started", \
		action_stack_ref, "_enter_discussion") \
		.set_params([flavor, CallableReference.from_callable(callable)]) \
		.set_flag(Flags.AppendSignalParamsToCall).set_owner(callable.get_object())

static func new_combat_state_change(callable: Callable) -> TimedEffect:
	var action_stack_ref = CombatNodeReference.new("Utility/ActionStackUtility")
	return TimedEffect.new(action_stack_ref, "combat_state_changed")._set_callable(callable)

#######################
## Methods for usage ##
#######################

## This should be the last thing executed on a Timed Effect.
## No more changes after it was connected.
func register(combat: Combat) -> void:
	if broken:
		return
	if solo:
		var others := combat.t_effects.get_effects(get_owner(), get_id())
		if others.any(func (te: TimedEffect): return te.solo):
			return
		for te in others:
			te.kill()
	combat.t_effects.add_effect(self)

## Adds custom parameters to the TE's callable.
## Those params will be the first params. They have to be serializable!
## (custom_set_params <optional> -> signal_params <optional> -> timed_effect_reference <optional>)
func set_params(params: Array) -> TimedEffect:
	call_params = params
	return self

## Prio determines the order of execution on the same signal. High Prio first.
func set_priority(prio: int) -> TimedEffect:
	priority = prio
	return self

## Set the owner, if you want to retrieve the TE later.
func set_owner(ref_or_obj: Object) -> TimedEffect:
	assert(ref_or_obj)
	assert(ref_or_obj is UniversalReference or ref_or_obj.has_method("get_reference"))
	if ref_or_obj is UniversalReference:
		owner_ref = ref_or_obj
	else:
		owner_ref = ref_or_obj.get_reference()
	return self

## Set the id, if you want to retrieve the TE later.
func set_id(_id: String) -> TimedEffect:
	id = _id
	return self

## If solo, the TE makes sure it is the only (living) TE with the same owner and id.
## This makes sense if the TE always has the same settings.
## A living solo TE prevents new solo one from getting added.
func set_solo(_solo := true) -> TimedEffect:
	solo = _solo
	return self

## The TE kills itself after the first successfull trigger.
func set_oneshot() -> TimedEffect:
	return set_trigger_count(1)

## The TE kills itself after the trigger_count successfull triggers.
func set_trigger_count(trigger_count: int) -> TimedEffect:
	triggers_left = trigger_count
	set_flag(Flags.LimitedTriggers)
	return self

## The TE ingores the first _delay triggers
func set_delay(_delay: int = 1) -> TimedEffect:
	delay = _delay
	return self

## Adds a self-reference as parameter to the TE's callable.
## (custom_set_params <optional> -> signal_params <optional> -> timed_effect_reference <optional>)
func give_timed_effect_as_parameter() -> TimedEffect:
	return set_flag(Flags.AppendSelfReferenceToCall)

## Adds the signals parameters to the TE's callable.
## (custom_set_params <optional> -> signal_params <optional> -> timed_effect_reference <optional>)
func give_signal_params_as_parameter() -> TimedEffect:
	return set_flag(Flags.AppendSignalParamsToCall)

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

## Deactivates a running TimedEffect. It does not trigger or allow a last callable.
func kill() -> void:
	dead = true

## Kaufland Freshboy, Freshboy Kaufland, skrr skrr swag
func force_freshness() -> TimedEffect:
	assert(call_obj, "TE must be created with _set_callable() for this.")
	assert(call_method, "TE must be created with _set_callable() for this.")
	if not Utility.script_has_actual_method(call_obj.get_script(), call_method):
		broken = true
	return self

######################
## Internal methods ##
######################

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
			push_error("Timed Effect: signal object %s has no signal %s" % [signal_obj, signal_name])
	else:
		push_error("Timed Effect: signal reference %s is invalid" % signal_ref)
	call_obj = call_ref.resolve(combat)
	if call_obj:
		if call_obj.has_method(call_method):
			connected_method = call_obj.get(call_method)
		else:
			push_error("Timed Effect: call object %s has no method %s" % [call_obj, call_method])
	else:
		push_error("Timed Effect: call reference %s is invalid" % call_ref)
	if owner_ref:
		owner_obj = owner_ref.resolve(combat)
	else:
		owner_obj = call_obj
	if Utility.has_int_flag(flags, Flags.ExtraCallOnDeath) or Utility.has_int_flag(flags, Flags.ReplaceCallOnDeath):
		if death_ref:
			death_obj = death_ref.resolve(combat)
			if death_obj.has_method(death_method):
				connected_death_method = death_obj.get(death_method)

## See Flags enum
func set_flag(flag: int, value := true) -> TimedEffect:
	if value:
		flags = Utility.add_int_flag(flags, flag)
	else:
		flags = Utility.remove_int_flag(flags, flag)
	return self

func set_death_callback(replace: bool, ref: UniversalReference, method: String, params := []) -> TimedEffect:
	assert(not effect_connected)
	death_ref = ref
	death_method = method
	death_params = params
	set_flag(Flags.ExtraCallOnDeath, not replace)
	set_flag(Flags.ReplaceCallOnDeath, replace)
	return self

func _validate() -> bool:
	if not effect_connected:
		push_error("Not connected TimedEffect tries to validate")
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
			elif call_obj is EntityLogic or \
				call_obj is EntityStatusLogic:
				if call_obj.entity.is_dead():
					dead = true
	return not dead

## ACTION
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
		else:
			push_error("Timed Effect triggered with invalid method.")
	if dead and (Utility.has_int_flag(flags, Flags.ReplaceCallOnDeath) or Utility.has_int_flag(flags, Flags.ExtraCallOnDeath)):
		if connected_death_method.is_valid():
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
	assert(callable.is_valid() and callable.is_standard(), "Only serializable callables.")
	assert(callable.get_object().has_method("get_reference"))
	call_obj = callable.get_object()
	call_ref = callable.get_object().get_reference()
	call_method = callable.get_method()
	return self

func get_owner() -> Object:
	return owner_obj

func get_id() -> String:
	return id
