class_name ActionTicket extends Object

enum State {Created, Running, Waiting, Finished, Aborted}

var callable: Callable
var object: Object:
	get:
		return callable.get_object()
var owner: Object
var state := State.Created
var stack_trace: Array

signal _go
signal removed

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
	await callable.call()
	finish()

func proceed():
	state = State.Running
	_go.emit()

func wait() -> Signal:
	assert(not can_be_removed())
	state = State.Waiting
	return _go

func abort():
	state = State.Aborted

func finish():
	assert(is_running())
	state = State.Finished

func can_be_removed() -> bool:
	return state == State.Finished or state == State.Aborted

func can_be_advanced() -> bool:
	return state == State.Created or state == State.Waiting

func is_running() -> bool:
	return state == State.Running

func remove():
	Utility.disconnect_all_connection(_go)
	removed.emit()
	free()
