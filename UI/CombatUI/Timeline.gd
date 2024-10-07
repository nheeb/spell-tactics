class_name TimelineUI extends Control

const EVENT_ICON_COUNT = 7

var transform_nodes : Array[Node2D] = []
var event_icons : Array[TimelineEventIcon] = []

var current_round := 0

var log_entry_queue: Array[LogEntry] = []

@onready var combat_ui: CombatUI = get_parent().get_parent()

func _ready() -> void:
	%IconTransforms.hide()
	for i in range(EVENT_ICON_COUNT):
		transform_nodes.append(%IconTransforms.get_node("Icon" + str(i+1)))

func build_timeline_from_log(log_util: LogUtility):
	current_round = log_util.get_current_round()
	append_empty_event_icons()
	#for entry in log_util.log_entries:
		#if entry.type == LogEntry.Type.Event or entry.type == LogEntry.Type.EventPrognose:
			#event_icons[entry.round_number - 1].set_log_entry(entry)
	refresh_visuals()

func refresh_round_label():
	set_round_label(current_round)

func set_round_label(_round: int):
	%RoundLabel.text = "Round %s" % _round

func refresh_visuals():
	set_round_label(current_round)
	append_empty_event_icons()
	for icon in event_icons:
		icon.hide()
	@warning_ignore("integer_division")
	var first := current_round - int(EVENT_ICON_COUNT/2) - 1
	for i in range(EVENT_ICON_COUNT):
		var turn := first + i
		if turn >= 0 and turn < len(event_icons):
			var turn_icon := event_icons[turn]
			if not i in [0, EVENT_ICON_COUNT-1]:
				turn_icon.show()
			turn_icon.transform = transform_nodes[i].transform

const EVENT_ICON = preload("res://UI/CombatUI/TimelineEventIcon.tscn")
func append_empty_event_icons(max_round := 0):
	if max_round <= 0:
		max_round = current_round + EVENT_ICON_COUNT
	while len(event_icons) < max_round:
		var new_icon = EVENT_ICON.instantiate()
		event_icons.append(new_icon)
		%EventIcons.add_child(new_icon)
		new_icon.transform = transform_nodes[-1].transform

@export var step_animation_duration := .4
func animate_step(step : int = 0):
	var direction : int = sign(step)
	var length : int = abs(step)
	var step_time : float = step_animation_duration / float(length)
	for i in range(length):
		@warning_ignore("integer_division")
		var old_first := current_round - int(EVENT_ICON_COUNT/2) - 1
		# Abort when going negative round
		if current_round + direction <= 0:
			continue
		current_round += direction
		refresh_round_label()
		var tween := VisualTime.new_tween()
		tween.set_parallel()
		for j in range(EVENT_ICON_COUNT):
			var old_index = old_first + j
			if not (j - direction) in range(EVENT_ICON_COUNT):
				pass
			else:
				var icon: TimelineEventIcon = Utility.array_safe_get(event_icons, old_index) as TimelineEventIcon
				if icon:
					tween.tween_property(icon, "transform", \
						transform_nodes[j-direction].transform, step_time)
					if (j - direction) in [0, EVENT_ICON_COUNT-1]:
						tween.tween_property(icon, "alpha", 0.0, step_time)
					elif (j - direction) in [1, EVENT_ICON_COUNT-2]:
						tween.tween_property(icon, "alpha", 1.0, step_time)

func jump_to_round(_round: int):
	animate_step(_round - current_round)

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_right"):
		#animate_step(1)
	#elif event.is_action_pressed("ui_left"):
		#animate_step(-1)
		
func process_log_entry_queue() -> void:
	if log_entry_queue.is_empty():
		return
	append_empty_event_icons(log_entry_queue.map(func(x): return x.round_number).max())
	for entry in log_entry_queue:
		event_icons[entry.round_number - 1].set_log_entry(entry)
	log_entry_queue.clear()
