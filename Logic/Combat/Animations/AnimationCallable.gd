class_name AnimationCallable extends AnimationObject

var callable: Callable
var object: Object
var method: StringName:
	get:
		return callable.get_method()

func _init(_callable: Callable):
	callable = _callable
	object = callable.get_object()

func play() -> void:
	if is_instance_valid(object):
		if _add_wait_ticket_to_args:
			var ticket := WaitTicket.new()
			ticket.resolved.connect(func(): animation_done_internally.emit(), CONNECT_ONE_SHOT)
			var bound_args = callable.get_bound_arguments()
			bound_args.append(ticket)
			Callable(object, method).callv(bound_args)
		elif object.has_method("get_wait_ticket_handler"):
			var handler := object.get_wait_ticket_handler() as WaitTicketHandler
			assert(handler)
			var ticket := WaitTicket.new()
			ticket.resolved.connect(func(): animation_done_internally.emit(), CONNECT_ONE_SHOT)
			handler.handle_ticket(ticket)
			callable.call()
			handler.clear()
		else:
			callable.call()
			animation_done_internally.emit()
	else:
		push_error("Callable has no valid object.")
		print_stack_trace_lines = true
		animation_done_internally.emit()

func _to_string() -> String:
	return "Anim: Do a callable"
