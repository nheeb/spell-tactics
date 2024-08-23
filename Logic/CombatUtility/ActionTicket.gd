class_name ActionTicket extends Object

enum State {Created, Running, Waiting, Finished, Aborted, Blocked}

var callable: Callable
var object: Object:
	get:
		return callable.get_object()
var method_name: StringName:
	get:
		return callable.get_method()
var owner: Object
var state := State.Created
var stack_trace: Array
var _remove_me := false
var _result: Variant

signal _go
signal removed
signal has_result(result: Variant)

class ActionTicketResult extends Object:
	var value: Variant = null
	func set_value(v: Variant):
		value = v
	func _init(s: Signal) -> void:
		s.connect(set_value, CONNECT_ONE_SHOT)

func _init(_callable: Callable, _owner = null) -> void:
	callable = _callable
	owner = _owner
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
	assert(is_running())
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
	Utility.disconnect_all_connection(_go)
	removed.emit()
	Utility.disconnect_all_connection(removed)
	if _result != null:
		has_result.emit(_result)
	Utility.disconnect_all_connection(has_result)
	free()

func _to_string() -> String:
	return "<AT:%s.%s>" % [object, method_name]
