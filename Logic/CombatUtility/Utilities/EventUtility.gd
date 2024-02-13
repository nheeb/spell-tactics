class_name EventUtility extends CombatUtility

var events: Array[Spell]
var current_event: SpellReference

# TODO serialize me
var enemy_meter := 3
const ENEMY_METER_MAX = 5

func get_regular_events() -> Array[Spell]:
	var array : Array[Spell] = []
	array.append_array(events.filter(\
		func (e): return e.type.is_event_spell and not e.type.is_enemy_event_spell))
	return array

func get_enemy_events() -> Array[Spell]:
	var array : Array[Spell] = []
	array.append_array(events.filter(\
		func (e): return e.type.is_enemy_event_spell))
	return array

func set_enemy_meter(value) -> AnimationCallback:
	enemy_meter = clamp(value, 0, ENEMY_METER_MAX)
	return combat.animation.callback(combat.ui, "set_enemy_meter", [enemy_meter]).set_min_duration(3)

func add_to_enemy_meter(value := 1) -> AnimationCallback:
	return set_enemy_meter(enemy_meter + value)

func is_enemy_meter_full() -> bool:
	return enemy_meter == ENEMY_METER_MAX

func reset_enemy_meter() -> AnimationCallback:
	return set_enemy_meter(0)

func process_event() -> void:
	var regular_events := get_regular_events()
	if regular_events.is_empty():
		combat.log.add("No Events loaded")
		return
	if current_event == null:
		current_event = regular_events.pick_random().get_reference()
		current_event.resolve(combat).event_logic.initialize_event()
	
	if current_event.resolve(combat).event_logic.advance_event():
		current_event = null

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
		
