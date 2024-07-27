class_name AnimationCallback extends AnimationObject

var reference: Object
var command: String
var parameters: Array

func _init(_reference: Object, _command: String, _parameters := []):
	reference = _reference
	command = _command
	parameters = _parameters

func play(level: Level) -> void:
	if is_instance_valid(reference):
		if reference.has_method("get_wait_ticket_handler"):
			var handler := reference.get_wait_ticket_handler() as WaitTicketHandler
			assert(handler)
			var ticket := WaitTicket.new()
			ticket.resolved.connect(func(): animation_done_internally.emit(),CONNECT_ONE_SHOT)
			handler.handle_ticket(ticket)
			reference.callv(command, parameters)
			handler.clear()
		elif reference.has_signal("animation_done"):
			push_error("Using deprecated signal animation_done (Use WaitTickets instead)")
			reference.animation_done.connect(func(): animation_done_internally.emit(),CONNECT_ONE_SHOT)
			reference.callv(command, parameters)
		else:
			reference.callv(command, parameters)
			animation_done_internally.emit()
	else:
		push_error("Animation on null reference")
		animation_done_internally.emit()

func _to_string() -> String:
	if len(parameters) == 1:
		return "Anim: Calling %s.%s(%s)" % [reference.name, command, parameters[0]]
	else:
		return "Anim: %s calls %s(%s)" % [reference.name, command, parameters]
