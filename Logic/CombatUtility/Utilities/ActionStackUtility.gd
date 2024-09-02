class_name ActionStackUtility extends CombatUtility

const FRAME_ACTION_MAX_MSECS = 10

var _stack : Array[ActionTicket]
var active_ticket: ActionTicket
var stack_is_filled := false
var consecutive_action_frames := 0
var consecutive_action_msecs := 0
var consecutive_action_start := 0
var block_start_time := 0

signal clear

###############################################
## Shortcut Methods for easy / default usage ##
###############################################

## Puts the active ticket in wait mode and returns the coresponding ticket
func wait() -> Signal:
	if active_ticket:
		return active_ticket.wait()
	else:
		push_error("Used wait without active ticket.")
		return clear

## Returns the ticket of the currently advancing action
func get_active_ticket() -> ActionTicket:
	return active_ticket

## Returns whether the stack is advancing a ticket right now
func is_running() -> bool:
	return get_active_ticket() != null

## Adds the ticket to the stack.
## Returns a signal which is emitted when the ticket is being removed
## (either finished or aborted).
## If called while the stack is running, it returns active_ticket.wait()
func process_ticket(action_ticket: ActionTicket) -> Signal:
	if is_running():
		push_before_active(action_ticket)
		return active_ticket.wait()
	else:
		push_back(action_ticket)
		return action_ticket.removed

## Turns the Callable into a ActionTicket and adds the ticket to the stack.
## Returns a signal which is emitted when the ticket is being removed
## (either finished or aborted).
func process_callable(callable: Callable) -> Signal:
	return process_ticket(ActionTicket.new(callable))

## Turns the PlayerAction into a ActionTicket and adds the ticket to the stack.
## Returns a signal which is emitted when the ticket is being removed
## (either finished or aborted).
func process_player_action(pa: PlayerAction, forced := false) -> Signal:
	return process_ticket(combat.input.player_action_ticket(pa, forced))

## Returns a result Object and adds the according ticket to the stack.
func process_result(callable: Callable) -> ActionTicket.ActionTicketResult:
	var action_ticket := ActionTicket.new(callable)
	if is_running():
		push_before_active(action_ticket)
	else:
		push_front(action_ticket)
	return action_ticket.get_result()

####################################
## Methods for adding new Tickets ##
####################################

func push_front(callable_or_ticket: Variant) -> void:
	var action_ticket: ActionTicket = callable_or_ticket \
		if callable_or_ticket is ActionTicket \
		else ActionTicket.new(callable_or_ticket)
	validate_new_ticket(action_ticket)
	_stack.push_front(action_ticket)
	mark_stack_as_filled()

func push_back(callable_or_ticket: Variant) -> void:
	var action_ticket: ActionTicket = callable_or_ticket \
		if callable_or_ticket is ActionTicket \
		else ActionTicket.new(callable_or_ticket)
	validate_new_ticket(action_ticket)
	_stack.push_back(action_ticket)
	mark_stack_as_filled()

func push_before_active(callable_or_ticket: Variant) -> void:
	var action_ticket: ActionTicket = callable_or_ticket \
		if callable_or_ticket is ActionTicket \
		else ActionTicket.new(callable_or_ticket)
	validate_new_ticket(action_ticket)
	_stack.insert(_stack.find(get_active_ticket()), action_ticket)
	mark_stack_as_filled()

func push_behind_active(callable_or_ticket: Variant) -> void:
	var action_ticket: ActionTicket = callable_or_ticket \
		if callable_or_ticket is ActionTicket \
		else ActionTicket.new(callable_or_ticket)
	validate_new_ticket(action_ticket)
	_stack.insert(_stack.find(get_active_ticket()) + 1, action_ticket)
	mark_stack_as_filled()

func push_before_other(callable_or_ticket: Variant, other: ActionTicket) -> void:
	assert(other in _stack)
	var action_ticket: ActionTicket = callable_or_ticket \
		if callable_or_ticket is ActionTicket \
		else ActionTicket.new(callable_or_ticket)
	validate_new_ticket(action_ticket)
	_stack.insert(_stack.find(other), action_ticket)
	mark_stack_as_filled()

func push_behind_other(callable_or_ticket: Variant, other: ActionTicket) -> void:
	assert(other in _stack)
	var action_ticket: ActionTicket = callable_or_ticket \
		if callable_or_ticket is ActionTicket \
		else ActionTicket.new(callable_or_ticket)
	validate_new_ticket(action_ticket)
	_stack.insert(_stack.find(other) + 1, action_ticket)
	mark_stack_as_filled()

######################
## Internal Methods ##
######################

func validate_new_ticket(action_ticket: ActionTicket):
	action_ticket.origin_ticket = get_active_ticket()
	assert(action_ticket.state == ActionTicket.State.Created \
			 and not action_ticket in _stack, \
			"ActionStack: Trying to add invalid action ticket")

func mark_stack_as_clear():
	block_start_time = 0
	if stack_is_filled:
		stack_is_filled = false
		combat.animation.play_animation_queue()
	if consecutive_action_frames > 1:
		combat.log.add("Calculated for %s msecs in %s frames (%.2f s)" % \
			[consecutive_action_msecs, consecutive_action_frames,
			float(consecutive_action_start - Time.get_ticks_msec()) / 1000.0])
		reset_action_time()
	clear.emit()

func mark_stack_as_filled():
	if not stack_is_filled:
		stack_is_filled = true
		# stack_process() this is DANGER

func mark_stack_as_blocked():
	if block_start_time == 0:
		block_start_time = Time.get_ticks_msec()
	var block_time := Time.get_ticks_msec() - block_start_time
	assert(block_time < 5000, \
		"ActionStack: Stack has been blocked for 5 seconds. Something is wrong.")

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

func stack_process() -> void:
	assert(not is_running(), \
		"This method should never be triggered by a running ticket.")
	if not stack_is_filled:
		mark_stack_as_clear()
		return
	var start_time := Time.get_ticks_msec()
	for i in range(1000):
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
		if ticket.is_blocked():
			note_action_time(action_time)
			mark_stack_as_blocked()
			return
		if ticket.can_be_advanced():
			active_ticket = ticket
			ticket.advance()
			active_ticket = null
		if ticket.can_be_removed():
			_stack.erase(ticket)
			ticket.remove()
	push_warning("ActionStack: Looped 1000 times this frame.")

func _process(delta: float) -> void:
	stack_process()
