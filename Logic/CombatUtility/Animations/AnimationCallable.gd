class_name AnimationCallable extends AnimationObject

var callable: Callable
var object: Object:
	get:
		return callable.get_object()
var method: StringName:
	get:
		return callable.get_method()

func _init(_callable: Callable):
	callable = _callable
	_build_stack_trace()

func play(level: Level) -> void:
	var reference := callable.get_object()
	if is_instance_valid(reference):
		if _add_ticket_to_parameter:
			var ticket := WaitTicket.new()
			ticket.resolved.connect(func(): animation_done_internally.emit(),CONNECT_ONE_SHOT)
			var bound_args = callable.get_bound_arguments()
			bound_args.append(ticket)
			var obj = callable.get_object()
			Callable(obj, method).callv(bound_args)
		elif reference.has_method("get_wait_ticket_handler"):
			var handler := reference.get_wait_ticket_handler() as WaitTicketHandler
			assert(handler)
			var ticket := WaitTicket.new()
			ticket.resolved.connect(func(): animation_done_internally.emit(),CONNECT_ONE_SHOT)
			handler.handle_ticket(ticket)
			callable.call()
			handler.clear()
		else:
			callable.call()
			animation_done_internally.emit()
	else:
		push_error("Callable has no valid object")
		animation_done_internally.emit()

func _to_string() -> String:
	return "Anim: Do a callable"
