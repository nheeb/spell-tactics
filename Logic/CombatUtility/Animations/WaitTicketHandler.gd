class_name WaitTicketHandler extends Object

## For handling AnimationQueue WaitTickets on the animating Node's side.
##
## This Handler is meant to be owned by Nodes that have animation functions.
## Those Nodes can take the ticket in said functions to resolve them when their
## animations are done.
## They can also leave the ticket in the handler and let it resolve
## automatically / instantly. [br][br]
## In order to be used by the AnimationQueue those Nodes [b]need to have[/b]
## a function get_wait_ticket_handler() returning the handler.

var _current_ticket : WaitTicket
var _ticket_touched := false

## If this is true, get_ticket returns a dummy WaitTicket even if there is
## no actual ticket being handled.
## (That might be helpful for calling animations also outside the queue)
var flag_create_dummy_tickets := true

## Fills the handler with a ticket.
## (Happens directly before the animation is played)
func handle_ticket(ticket: WaitTicket) -> void:
	assert(_current_ticket == null)
	_current_ticket = ticket
	_ticket_touched = false

## Returns the current ticket and marks it as touched so it doesn't get
## resolved automatically.
func get_ticket() -> WaitTicket:
	_ticket_touched = true
	if _current_ticket:
		return _current_ticket
	if flag_create_dummy_tickets:
		return WaitTicket.new()
	return null

## Deletes the current ticket and resolves it when untouched.
## (Happens directly after an animation is played)
func clear() -> void:
	assert(_current_ticket)
	if not _ticket_touched:
		_current_ticket.resolve()
	_current_ticket = null
	_ticket_touched = false

## Delegates the ticket responsibility to another object.
## (Only if that object has or is a handler)
func delegate(other_object: Object) -> void:
	if other_object.has_method("get_wait_ticket_handler"):
		var handler : WaitTicketHandler = other_object.get_wait_ticket_handler()
		handler.handle_ticket(get_ticket())
	elif other_object is WaitTicketHandler:
		other_object.handle_ticket(get_ticket())
