extends Control

const EVENT_ICON_COUNT = 7

var transform_nodes : Array[Node2D] = []
var event_icons : Array[TimelineEventIcon] = []

var current_round := 0

func _ready() -> void:
	%IconTransforms.hide()
	for i in range(EVENT_ICON_COUNT):
		transform_nodes.push_front(%IconTransforms.get_node("Icon" + str(i+1)))

func build_timeline_from_log(log_util: LogUtility):
	current_round = log_util.get_current_round()
	append_empty_event_icons()
	for entry in log_util.log_entries:
		if entry.type == LogEntry.Type.Event or entry.type == LogEntry.Type.EventPrognose:
			event_icons[entry.round_number - 1].set_log_entry(entry)
	refresh_visuals()

func set_round_label(_round: int):
	%RoundLabel.text = "Round %s" % _round

func refresh_visuals():
	set_round_label(current_round)
	append_empty_event_icons()
	for icon in event_icons:
		icon.hide()
	var first := current_round - int(EVENT_ICON_COUNT/2)
	for i in range(EVENT_ICON_COUNT):
		var turn := first + i
		if turn >= 0 and turn < len(event_icons):
			var turn_icon := event_icons[turn]
			turn_icon.show()
			turn_icon.transform = transform_nodes[turn].transform

const EVENT_ICON = preload("res://UI/CombatUI/TimelineEventIcon.tscn")
func append_empty_event_icons():
	while len(event_icons) < current_round + EVENT_ICON_COUNT:
		var new_icon = EVENT_ICON.instantiate()
		event_icons.append(new_icon)
		%EventIcons.add_child(new_icon)

@export var step_animation_duration := .4
func animate_step(step : int = 0):
	var direction : int = sign(step)
	var length : int = abs(step)
	var step_time : float = step_animation_duration / float(length)
	for i in range(length):
		var old_first := current_round - int(EVENT_ICON_COUNT/2)
		current_round += direction
		var tween := VisualTime.create_tween()
		tween.set_parallel()
		for j in range(EVENT_ICON_COUNT):
			var old_index = old_first + j
			if j == 0 and direction == 1:
				pass
			elif j == EVENT_ICON_COUNT - 1 and direction == -1:
				pass
			else:
				var icon: TimelineEventIcon = Utility.array_safe_get(event_icons, old_index) as TimelineEventIcon
				if icon:
					tween.tween_property(icon, "transform", transform_nodes[j+direction], step_time)
