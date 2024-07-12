class_name EventUtility extends CombatUtility

## { RoundNumber (int) -> ScheduledEvents (Array[CombatEventSchedule]) }
var event_timeline: Dictionary

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

func get_active_events() -> Array[CombatEvent]:
	return all_events.filter(func (e): return e.active)

func add_event_and_activate(event: CombatEvent, advance_when_activate := false):
	assert(not event in all_events, "Added event that was already in the list")
	all_events.append(event)
	event.activate()
	if advance_when_activate:
		event.advance()

## This method will be called every end step. This is where all the activation
## and advancing happens.
func process_events() -> void:
	process_enemy_events()
	process_event_schedules()
	process_active_events()

func process_enemy_events():
	process_enemy_event()

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
const ENEMY_METER_MAX = 5

func get_regular_events() -> Array[Spell]:
	assert(false)
	return []
	#var array : Array[Spell] = []
	#array.append_array(events.filter(\
		#func (e): return e.type.is_event_spell and not e.type.is_enemy_event_spell))
	#return array

func get_enemy_events() -> Array[Spell]:
	var array : Array[Spell] = []
	assert(false)
	return []
	#array.append_array(events.filter(\
		#func (e): return e.type.is_enemy_event_spell))
	#return array

func set_enemy_meter(value) -> AnimationCallback:
	enemy_meter = clamp(value, 0, ENEMY_METER_MAX)
	return combat.animation.callback(combat.ui, "set_enemy_meter", [enemy_meter]).set_min_duration(3)

func add_to_enemy_meter(value := 1) -> AnimationCallback:
	return set_enemy_meter(enemy_meter + value)

func is_enemy_meter_full() -> bool:
	return enemy_meter == ENEMY_METER_MAX

func reset_enemy_meter() -> AnimationCallback:
	return set_enemy_meter(0)

#func process_event() -> void:
	#var regular_events := get_regular_events()
	#if regular_events.is_empty():
		#combat.log.add("No Events loaded")
		#return
#
	## If no current event -> pick a new one 
	#if current_event == null:
		#current_event = regular_events.pick_random().get_reference()
		#
		#current_event.resolve(combat).event_logic.initialize_event()
	#
	## If advancing the current events ends it -> set current event to null
	#if current_event.resolve(combat).event_logic.advance_event():
		#current_event = null

func process_enemy_event() -> void:
	if is_enemy_meter_full():
		var enemy_events := get_enemy_events()
		if enemy_events.is_empty():
			combat.log.add("No Enemy Events loaded")
			return
		reset_enemy_meter()
		var enemy_event : Spell = enemy_events.pick_random() as Spell
		assert(enemy_event)
		assert(enemy_event.type.is_enemy_event_spell)
		enemy_event.logic.initialize_event()
		enemy_event.logic.advance_event()
		
