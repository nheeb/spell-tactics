class_name ActionStackUtility extends CombatUtility

const FRAME_ACTION_MAX_MSECS = 10

var _stack : Array[ActionTicket]
var stack_string: PackedStringArray:
	get:
		return PackedStringArray(Array(_stack).map(
			func (at: ActionTicket):
				return at._to_string()
		))
var active_ticket: ActionTicket
var stack_is_filled := false
var consecutive_action_frames := 0
var consecutive_action_msecs := 0
var consecutive_action_start := 0
var consecutive_action_total := 0
var consecutive_action_process_runs := 0
var block_start_time := 0
var _preset_flavor: ActionFlavor

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
func process_ticket(action_ticket: ActionTicket, warn_if_not_running := true) -> Signal:
	if is_running():
		push_before_active(action_ticket)
		return active_ticket.wait()
	else:
		push_back(action_ticket)
		if warn_if_not_running:
			push_warning("Used process_ticket with no active ticket. Something might be wrong.")
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
	return process_ticket(combat.input.player_action_ticket(pa, forced), false)

## Returns the result of a callable as action stack coroutine.
## Use it with await:
## var x = await combat.action_stack.get_result(uwu) 
func get_result(callable: Callable) -> Variant:
	assert(active_ticket, "This can only be used during an active ticket.")
	var result := process_result(callable)
	await wait()
	return result.result

## Returns a result Object and adds the according ticket to the stack.
func process_result(callable: Callable) -> ActionTicket.ActionTicketResult:
	var action_ticket := ActionTicket.new(callable)
	if is_running():
		push_before_active(action_ticket)
	else:
		push_front(action_ticket)
	return action_ticket.get_result()

## With discussions you can easily have some TimedEffects decide whether they want
## to influence the calculation of a value. Flavor decides if they get activated.
func start_discussion(base_value, flavor) -> ActionTicket.ActionTicketResult:
	if flavor and flavor is ActionFlavor:
		preset_flavor(flavor)
	return process_result(_start_discussion.bind(base_value))

## Returns the result of a value discussion (see start_discussion())
func get_discussion_result(base_value, flavor) -> Variant:
	assert(active_ticket, "This can only be used during an active ticket.")
	var result := start_discussion(base_value, flavor)
	await wait()
	return result.result

## For easy adding flavors to actions: 
## (Only) The next action added to the stack will get this flavor.
func preset_flavor(flavor: ActionFlavor):
	if flavor == null:
		push_warning("Pre setting null as flavor.")
	if _preset_flavor != null:
		push_error("There already is a loaded flavor. That should not be.")
	_preset_flavor = flavor

####################################
## Methods for adding new Tickets ##
####################################

func push_front(callable_or_ticket: Variant) -> void:
	var action_ticket := ActionTicket.from(callable_or_ticket)
	validate_new_ticket(action_ticket)
	_stack.push_front(action_ticket)
	mark_stack_as_filled()

func push_back(callable_or_ticket: Variant) -> void:
	var action_ticket := ActionTicket.from(callable_or_ticket)
	validate_new_ticket(action_ticket)
	_stack.push_back(action_ticket)
	mark_stack_as_filled()

func push_before_active(callable_or_ticket: Variant) -> void:
	if get_active_ticket() == null:
		push_warning("Used push_before_active without active ticket.")
		push_front(callable_or_ticket)
		return
	var action_ticket := ActionTicket.from(callable_or_ticket)
	validate_new_ticket(action_ticket)
	_stack.insert(_stack.find(get_active_ticket()), action_ticket)
	mark_stack_as_filled()

func push_behind_active(callable_or_ticket: Variant) -> void:
	if get_active_ticket() == null:
		push_warning("Used push_behind_active without active ticket.")
		push_back(callable_or_ticket)
		return
	var action_ticket := ActionTicket.from(callable_or_ticket)
	validate_new_ticket(action_ticket)
	_stack.insert(_stack.find(get_active_ticket()) + 1, action_ticket)
	mark_stack_as_filled()

func push_before_other(callable_or_ticket: Variant, other: ActionTicket) -> void:
	assert(other in _stack)
	var action_ticket := ActionTicket.from(callable_or_ticket)
	validate_new_ticket(action_ticket)
	_stack.insert(_stack.find(other), action_ticket)
	mark_stack_as_filled()

func push_behind_other(callable_or_ticket: Variant, other: ActionTicket) -> void:
	assert(other in _stack)
	var action_ticket := ActionTicket.from(callable_or_ticket)
	validate_new_ticket(action_ticket)
	_stack.insert(_stack.find(other) + 1, action_ticket)
	mark_stack_as_filled()

######################
## Internal Methods ##
######################

## Mainly setting the origin_ticket and loaded flavor here
func validate_new_ticket(action_ticket: ActionTicket):
	assert(action_ticket.state == ActionTicket.State.Created \
			and not action_ticket in _stack, \
			"ActionStack: Trying to add invalid action ticket")
	action_ticket.origin_ticket = get_active_ticket()
	if _preset_flavor:
		if action_ticket.flavor:
			push_error("Ticket already has a flavor. \
				It will be overwritten by the loaded one.")
		action_ticket.flavor = _preset_flavor
		_preset_flavor = null
	if _preset_combat_change:
		action_ticket.changes_combat = true
		_preset_combat_change = false

func mark_stack_as_clear():
	block_start_time = 0
	if stack_is_filled:
		stack_is_filled = false
		combat.animation.play_animation_queue()
	if consecutive_action_frames > 3:
		var current_time := Time.get_ticks_msec()
		var real_duration := Time.get_ticks_msec() - consecutive_action_start
		combat.log.add(
			"Calculated %s actions in %s msecs using %s frames and %s runs (total %.2f s)" % \
			[
				consecutive_action_total,
				consecutive_action_msecs,
				consecutive_action_frames,
				consecutive_action_process_runs,
				float(real_duration) / 1000.0
			]
		)
	reset_action_time()
	clear.emit()

func mark_stack_as_filled():
	if not stack_is_filled:
		stack_is_filled = true
		# stack_process() -> dont do it this is DANGER

## Still no idea why this feature exists...
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
	consecutive_action_total = 0
	consecutive_action_process_runs = 0

func note_action_time(action_time: int, action_process_runs: int, action_total: int):
	if consecutive_action_frames == 0:
		consecutive_action_start = Time.get_ticks_msec() - action_time
	consecutive_action_frames += 1
	consecutive_action_msecs += action_time
	consecutive_action_process_runs += action_process_runs
	consecutive_action_total += action_total
	assert(consecutive_action_frames < 500, "ActionStack: Something probably went wrong.")

func stack_process() -> void:
	assert(not is_running(), \
		"This method should never be triggered by a running ticket.")
	if not stack_is_filled:
		mark_stack_as_clear()
		return
	var start_time := Time.get_ticks_msec()
	var action_total := 0
	for i in range(1000):
		var current_time := Time.get_ticks_msec()
		var action_time := current_time - start_time
		if action_time > FRAME_ACTION_MAX_MSECS:
			note_action_time(action_time, i + 1, action_total)
			return
		if _stack.is_empty():
			note_action_time(action_time, i + 1, action_total)
			mark_stack_as_clear()
			return
		var ticket: ActionTicket = _stack.front() as ActionTicket
		assert(not ticket.is_running(), \
			"ActionStack: Tickets should never be running at this point")
		if ticket.is_blocked():
			push_warning("A ticket is blocked. What happened?")
			note_action_time(action_time, i + 1, action_total)
			mark_stack_as_blocked()
			return
		if ticket.can_be_advanced():
			active_ticket = ticket
			if ticket.can_announce_flavor():
				_announce_active_flavor()
			else:
				ticket.advance()
			active_ticket = null
		elif ticket.can_be_removed():
			combat.log.register_entry(ticket.create_log_entry())
			if ticket.changes_combat:
				push_behind_other(_trigger_combat_changed, ticket)
			if ticket.can_announce_flavor():
				push_warning("Soon to be removed ticket has unannounced flavor.")
			_stack.erase(ticket)
			ticket.remove()
			action_total += 1
		else:
			push_error("Ticket can neither be advanced or removed.")
	push_warning("ActionStack: Looped 1000 times this frame.")

func _process(delta: float) -> void:
	stack_process()

#########################
## Flavor Announcement ##
#########################

signal flavor_announced(flavor: ActionFlavor)

func set_active_flavor(flavor: ActionFlavor) -> Signal:
	assert(active_ticket, "An active ticket is needed to set the flavor.")
	if active_ticket.flavor:
		push_warning("Setting flavor for active ticket which already has one.\
		Is this intended?")
	active_ticket.flavor = flavor
	_announce_active_flavor()
	return wait()

func announce_flavor(flavor: ActionFlavor) -> Signal:
	preset_flavor(flavor)
	return process_callable(func(): pass)

func _announce_active_flavor():
	assert(active_ticket)
	assert(active_ticket.flavor)
	flavor_announced.emit(active_ticket.flavor)
	active_ticket._has_flavor_to_announce = false

#################
## Discussions ##
#################

signal discussion_started(discussion: Discussion)

## RESULT Should only be touched by the method start_discussion
func _start_discussion(base_value):
	var discussion := Discussion.new(base_value)
	discussion_started.emit(discussion)
	await wait()
	return discussion.value

## TE
## This method will be the target of TimedEffects created with
## TimedEffect.new_discussion_entry(flavor, callable)
func _enter_discussion(target_flavor: ActionFlavor, call_ref: CallableReference,\
					discussion: Discussion):
	assert(active_ticket)
	assert(active_ticket.get_flavor(true))
	if target_flavor.fits_into(active_ticket.get_flavor(true), combat):
		var callable := call_ref.get_callable(combat)
		callable.call(discussion)

################################
## Global Combat State Change ##
################################

## Sometimes we want to cache values everytime the combat changes.
## Especially when getting those values require big calculations or using Results.

var _preset_combat_change := false
signal combat_changed

## ACTION
func _trigger_combat_changed():
	combat_changed.emit()
	await wait()
	pass

func mark_combat_changed():
	if active_ticket:
		active_ticket.changes_combat = true
	else:
		force_combat_change_update()

func force_combat_change_update() -> Signal:
	return process_callable(_trigger_combat_changed)

func preset_combat_change():
	_preset_combat_change = true
