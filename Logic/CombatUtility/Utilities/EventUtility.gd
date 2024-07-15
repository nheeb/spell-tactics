class_name EventUtility extends CombatUtility

## { RoundNumber (int) -> ScheduledEvents (Array[CombatEventSchedule]) }
var event_timeline: Dictionary
var enemy_event_queue: Array[EnemyEventPlan]
var all_events: Array[CombatEvent]

func add_event_schedule(event_schedule: CombatEventSchedule, round_number: int):
	for schedule_list in event_timeline.values():
		schedule_list.erase(event_schedule)
	if event_timeline.has(round_number):
		var schedules := event_timeline[round_number] as Array
		assert(schedules)
		schedules.append(event_schedule)
		schedules.sort_custom(
			func (a, b):
				if not a.event_type: return true
				if not b.event_type: return false
				return a.event_type.order < b.event_type.order
		)
	else:
		event_timeline[round_number] = [event_schedule]

func add_event_schedule_for_this_round(es: CombatEventSchedule, delay := 0):
	add_event_schedule(es, combat.current_round + delay)

func get_event_schedule_round_number(event_schedule: CombatEventSchedule) -> int:
	for round_number in event_timeline.keys():
		if event_schedule in event_timeline[round_number]:
			return round_number
	printerr("EventSchedule not in timeline")
	return 0

func get_next_enemy_event_plan() -> EnemyEventPlan:
	return Utility.array_safe_get(enemy_event_queue.filter(
		func (e): return not e.event_created
	), 0) as EnemyEventPlan

func get_active_events() -> Array[CombatEvent]:
	return all_events.filter(func (e): return e.active)

func add_event(event: CombatEvent):
	assert(not event in all_events, "Added event that was already in the list")
	all_events.append(event)

func add_event_and_activate(event: CombatEvent, advance_when_activate := false):
	add_event(event)
	event.activate()
	if advance_when_activate:
		event.advance()

## This method will be called every end step. This is where all the activation
## and advancing happens.
func process_events() -> void:
	process_enemy_events()
	process_event_schedules()
	process_active_events()

func process_event_schedules():
	var round := combat.current_round
	if round in event_timeline.keys():
		for schedule in event_timeline[round]:
			schedule = schedule as CombatEventSchedule
			assert(schedule)
			add_event_and_activate(schedule.create_event(combat))

func process_active_events():
	for event in get_active_events():
		event.advance()

# TODO Nitai serialize this
var enemy_meter := 0
var enemy_meter_max := 0
var current_enemy_event: CombatEventReference

func process_enemy_events():
	if not current_enemy_event:
		discover_next_enemy_event()
	add_to_enemy_meter()
	try_to_activate_enemy_event()
	if not current_enemy_event:
		discover_next_enemy_event()

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
		event.discover()

func try_to_activate_enemy_event():
	if current_enemy_event:
		if is_enemy_meter_full():
			current_enemy_event.get_enemy_event(combat).activate()
			current_enemy_event = null
			reset_enemy_meter()

func connect_enemy_meter_to_event(event: EnemyEvent) -> AnimationObject:
	return combat.animation.callback(combat.ui, "set_enemy_meter_event", [event])

func set_enemy_meter(value: int) -> AnimationCallback:
	enemy_meter = clamp(value, 0, enemy_meter_max)
	return combat.animation.callback(combat.ui, "set_enemy_meter", [enemy_meter])

func set_enemy_meter_max(value: int) -> AnimationObject:
	return combat.animation.callback(combat.ui, "set_enemy_meter_max", [value])

func add_to_enemy_meter(value := 1) -> AnimationCallback:
	return set_enemy_meter(enemy_meter + value)

func is_enemy_meter_full() -> bool:
	return enemy_meter == enemy_meter_max

func reset_enemy_meter() -> AnimationCallback:
	return set_enemy_meter(0)
