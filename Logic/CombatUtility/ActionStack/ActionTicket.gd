class_name ActionTicket extends RefCounted
## These are the objects in our ActionStack. Each ticket contains a callable.

enum State {
	Created, # Just created. Not touched.
	Running, # Currently running as active ticket.
	Waiting, # Was running at some point. Now it's waiting to continue.
	Finished, # Finished with doing what it wants.
	Aborted, # Interupted at some point and not meant to be resumed.
	Blocked, # Apparently you can block the stack but I forgot what that was for...
}

## The one and only callable
var callable: Callable
var object: Object:
	get:
		return callable.get_object()
var method_name: StringName:
	get:
		return callable.get_method()
## Object describing the action. Used to hook something onto that action.
## To be clean use action_stack.load_flavor() to set and get_flavor() to get.
var flavor: ActionFlavor
var state : State = State.Created
## Stack trace of the ticket creation for debugging.
var stack_trace: Array
var stack_trace_string: String:
	get:
		var s := ""
		for d in stack_trace:
			if d is Dictionary:
				for k in d.keys():
					s += "%s:%s|" % [k, d[k]]
				s += "\n"
		return s 
var _remove_me := false:
	set(x):
		_remove_me = x
		if x and DebugInfo.ACTIVE:
			_removing_stack_strace = get_stack()
var _removing_stack_strace
var _result: Variant
var was_removed := false
## Other Ticket that caused the creation of this ticket.
var origin_ticket : ActionTicket
## TBD not implemented yet. Entries that are created during the ticket. Do we need that?
var log_entries : Array[LogEntry]
var changes_combat := false

signal _go
signal removed
signal has_result(result: Variant)

## If a ticket should return something it happens via this object.
## Use get_result()
class ActionTicketResult extends RefCounted:
	signal resolved
	var value: Variant = null
	var result: Variant: 
		get: return value
	func set_value(v: Variant):
		value = v
		resolved.emit()
	func _init(s: Signal) -> void:
		s.connect(set_value, CONNECT_ONE_SHOT)

func _init(_callable: Callable, _flavor = null) -> void:
	callable = _callable
	flavor = _flavor
	stack_trace = get_stack()

func advance():
	match state:
		State.Created:
			start()
		State.Waiting:
			proceed()
		_:
			push_error("ActionTicket: Advanced in illegal state {}." % state)

func start():
	state = State.Running
	_result = await callable.call()
	finish()

func proceed():
	state = State.Running
	_go.emit()

func wait() -> Signal:
	assert(not can_be_removed())
	state = State.Waiting
	return _go

func abort() -> Signal:
	state = State.Aborted
	_remove_me = true
	return removed

## Returns a signal which emits when the ticket is removed
func finish() -> Signal:
	state = State.Finished
	_remove_me = true
	return removed

func block():
	assert(is_running())
	state = State.Blocked

func unblock():
	assert(is_blocked())
	state = State.Running

func can_be_removed() -> bool:
	return _remove_me

func can_be_advanced() -> bool:
	return state == State.Created or state == State.Waiting

func is_running() -> bool:
	return state == State.Running

func is_blocked() -> bool:
	return state == State.Blocked

func get_result() -> ActionTicketResult:
	return ActionTicketResult.new(has_result)

func remove():
	Utility.disconnect_all_connections(_go)
	removed.emit()
	Utility.disconnect_all_connections(removed)
	if _result != null:
		has_result.emit(_result)
	Utility.disconnect_all_connections(has_result)
	origin_ticket = null
	was_removed = true

func _to_string() -> String:
	return "<AT:%s.%s>" % [object, method_name]

## If deep = true it returns the origin's flavor of the ticket itself has none.
func get_flavor(deep := false) -> ActionFlavor:
	if flavor:
		return flavor
	if origin_ticket and deep:
		return origin_ticket.get_flavor()
	return null
