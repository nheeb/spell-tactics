class_name EventUtility extends CombatUtility

## This method will be called every end step. This is where all the activation
## and advancing happens.
func process_events() -> void:
	await combat.action_stack.process_callable(process_enemy_events)
	await combat.action_stack.process_callable(process_event_schedules)
	await combat.action_stack.process_callable(process_active_events)

############################
## Handling Combat Events ##
############################

## The planned events (change that by editing it in the CombatState directly)
## { RoundNumber (int) -> ScheduledEvents (Array[CombatEventSchedule]) }
#var event_timeline: Dictionary
var event_schedules: Array[CombatEventSchedule]
## All the CombatEvent instances (not the schedules)
var all_events: Array[CombatEvent]

func add_event_schedule(event_schedule: CombatEventSchedule):
	assert(event_schedule not in event_schedules)
	event_schedules.append(event_schedule)

func add_event_schedule_for_this_round(es: CombatEventSchedule, delay := 0):
	es.scheduled_round = combat.current_round + delay
	add_event_schedule(es)

func get_active_events() -> Array[CombatEvent]:
	var active_events := all_events.filter(func (e): return e.active)
	active_events.sort_custom(
		func(a: CombatEvent, b: CombatEvent):
			return a.type.order < b.type.order
	)
	return active_events

func add_event(event: CombatEvent):
	assert(not (event in all_events), "Added event that was already in the list")
	all_events.append(event)

## ACTION
func add_event_and_activate(event: CombatEvent, advance_when_activate := false):
	add_event(event)
	await event.activate()
	if advance_when_activate:
		await event.advance()

func get_unused_schedules_for_round(r: int) -> Array[CombatEventSchedule]:
	var schedules: Array[CombatEventSchedule] = event_schedules.filter(
		func (ces: CombatEventSchedule) -> bool:
			return ces.event_type and (not ces.was_deserialized) \
				and ces.scheduled_round <= r
	)
	schedules.sort_custom(
		func (a, b):
			return a.event_type.order < b.event_type.order
	)
	return schedules

## ACTION
func process_event_schedules():
	var game_round := combat.current_round
	for schedule in get_unused_schedules_for_round(game_round):
		await add_event_and_activate(schedule.create_event(combat))

## ACTION
func process_active_events():
	for event in get_active_events():
		await event.advance()

###########################
## Handling Enemy Events ##
###########################

const ENEMY_METER_GAIN_DEFAULT = 1

## The planned enemy events (also edit this in the CombatState)
var enemy_event_queue: Array[EnemyEventPlan]
# TODO Nitai serialize this
var enemy_meter := 0
var enemy_meter_max := 0
var current_enemy_event: CombatObjectReference

## ACTION
func process_enemy_events():
	if not current_enemy_event:
		await discover_next_enemy_event()
	add_to_enemy_meter()
	await try_to_activate_enemy_event()
	if not current_enemy_event:
		await discover_next_enemy_event()

func get_next_enemy_event_plan() -> EnemyEventPlan:
	var plan := Utility.array_safe_get(enemy_event_queue.filter(
		func (e: EnemyEventPlan):
			return not e.was_deserialized
	), 0) as EnemyEventPlan
	if plan:
		return plan
	var default := Utility.array_safe_get(enemy_event_queue.filter(
		func (e): return e.use_as_default
	), 0) as EnemyEventPlan
	if default:
		var new_plan : EnemyEventPlan = default.duplicate() as EnemyEventPlan
		new_plan.was_deserialized = false
		enemy_event_queue.append(new_plan)
		return new_plan
	return null

## ACTION
func discover_next_enemy_event():
	if current_enemy_event:
		assert(not current_enemy_event.get_enemy_event(combat).active, \
				"Discovering a new enemy event although the previous one \
				has not been activated.")
	var plan := get_next_enemy_event_plan()
	if plan:
		var event : EnemyEvent = plan.create_event(combat) as EnemyEvent
		add_event(event)
		current_enemy_event = event.get_reference()
		connect_enemy_meter_to_event(event)
		await event.discover()

## ACTION
func try_to_activate_enemy_event():
	if current_enemy_event:
		if is_enemy_meter_full():
			await current_enemy_event.get_enemy_event(combat).activate()
			current_enemy_event = null
			reset_enemy_meter()

func connect_enemy_meter_to_event(event: EnemyEvent) -> AnimationObject:
	enemy_meter_max = event.get_enemy_meter_costs()
	return combat.animation.call_method(combat.ui, "set_enemy_meter_event", [event])

func set_enemy_meter(value: int) -> AnimationCallable:
	enemy_meter = clamp(value, 0, enemy_meter_max)
	return combat.animation.call_method(combat.ui, "set_enemy_meter", [enemy_meter])

func set_enemy_meter_max(value: int) -> AnimationObject:
	return combat.animation.call_method(combat.ui, "set_enemy_meter_max", [value])

func add_to_enemy_meter(value := ENEMY_METER_GAIN_DEFAULT) -> AnimationCallable:
	# I removed discovering here because add to meter should not be an ACTION
	#if not current_enemy_event:
		#await discover_next_enemy_event()
	return set_enemy_meter(enemy_meter + value)

func is_enemy_meter_full() -> bool:
	return enemy_meter == enemy_meter_max

func reset_enemy_meter() -> AnimationCallable:
	return set_enemy_meter(0)
