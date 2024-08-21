class_name ActionStackUtility extends CombatUtility

const FRAME_ACTION_MAX_MSECS = 10

var _stack : Array[ActionTicket]
var _active_ticket: ActionTicket
var stack_is_filled := false
var consecutive_action_frames := 0
var consecutive_action_msecs := 0
var consecutive_action_start := 0

signal clear

#####################################
## Shortcut Methods for easy usage ##
#####################################

## Getting the ticket of the currently advancing action
func get_active_ticket() -> ActionTicket:
	return _active_ticket

func process_ticket(action_ticket: ActionTicket) -> Signal:
	push_front(action_ticket)
	return action_ticket.removed

####################################
## Methods for adding new Tickets ##
####################################

func push_front(action_ticket: ActionTicket) -> void:
	validate_new_ticket(action_ticket)
	_stack.push_front(action_ticket)
	mark_stack_as_filled()

func push_back(action_ticket: ActionTicket) -> void:
	validate_new_ticket(action_ticket)
	_stack.push_back(action_ticket)
	mark_stack_as_filled()

func push_before_active(action_ticket: ActionTicket) -> void:
	validate_new_ticket(action_ticket)
	_stack.insert(_stack.find(get_active_ticket()), action_ticket)
	mark_stack_as_filled()

func push_behind_active(action_ticket: ActionTicket) -> void:
	validate_new_ticket(action_ticket)
	_stack.insert(_stack.find(get_active_ticket()) + 1, action_ticket)
	mark_stack_as_filled()

######################
## Internal methods ##
######################

func validate_new_ticket(action_ticket: ActionTicket):
	assert(action_ticket.state == ActionTicket.State.Created \
			 and not action_ticket in _stack, \
			"ActionStack: Trying to add invalid action ticket")


func mark_stack_as_clear():
	if stack_is_filled:
		stack_is_filled = false
		combat.animation.play_animation_queue()
	if consecutive_action_frames > 0:
		combat.log.add("Calculated for %s msecs in %s frames (%.2f s)" % \
			[consecutive_action_msecs, consecutive_action_frames,
			float(consecutive_action_start - Time.get_ticks_msec()) / 1000.0])
		reset_action_time()
	clear.emit()

func mark_stack_as_filled():
	stack_is_filled = true

func reset_action_time():
	consecutive_action_frames = 0
	consecutive_action_msecs = 0
	consecutive_action_start = 0

func note_action_time(action_time: int):
	if consecutive_action_frames == 0:
		consecutive_action_start = Time.get_ticks_msec() - action_time
	consecutive_action_frames += 1
	consecutive_action_msecs += action_time
	assert(consecutive_action_frames < 120, "ActionStack: Something probably went wrong.")

func _process(delta: float) -> void:
	if _stack.is_empty():
		mark_stack_as_clear()
		return
	var start_time := Time.get_ticks_msec()
	while true:
		var current_time := Time.get_ticks_msec()
		var action_time := current_time - start_time
		if action_time > FRAME_ACTION_MAX_MSECS:
			note_action_time(action_time)
			return
		if _stack.is_empty():
			note_action_time(action_time)
			mark_stack_as_clear()
			return
		var ticket: ActionTicket = _stack.front() as ActionTicket
		assert(not ticket.is_running(), \
			"ActionStack: Tickets should never be running at this point")
		if ticket.can_be_advanced():
			_active_ticket = ticket
			ticket.advance()
			_active_ticket = null
		if ticket.can_be_removed():
			_stack.erase(ticket)
			ticket.remove()
