class_name AnimationObject extends RefCounted
## This is the abstract Animation Object

######################
## Internal Methods ##
######################

signal animation_done
signal animation_done_internally

var combat: Combat
var level: Level:
	get:
		return combat.level

func setup(_combat: Combat):
	combat = _combat

## Override this to set what the animation does.
## Always emit animation_done_internally at the end
func play() -> void:
	pass

func _play() -> void:
	DebugInfo.current_animations.append(self)
	animation_done_internally.connect(internal_animation_done)
	await combat.animation.animation_process
	if delay > 0.0:
		await VisualTime.new_timer(delay).timeout
	global_start_time = VisualTime.visual_global_time
	if max_duration != 0.0:
		if max_duration < max(min_duration, 0.0) :
			push_error("AnimationObject: Invalid max / min durations")
		VisualTime.new_timer(max_duration).timeout.connect(internal_animation_done)
	play()

func internal_animation_done() -> void:
	var ellapsed_time : float = abs(VisualTime.visual_global_time - global_start_time)
	if ellapsed_time < min_duration:
		await VisualTime.new_timer(min_duration - ellapsed_time).timeout
	DebugInfo.current_animations.erase(self)
	animation_done.emit()

###########################
## Configuration Methods ##
###########################

enum Flags {
	PlayAfterStep,
	PlayWithStep,
	ExtendStep
}

var flag: Flags = Flags.PlayAfterStep
var delay := 0.0
var min_duration := 0.0
var max_duration := 0.0
var global_start_time : float
var seperate_queue_id := ""

func set_flag(f: Flags) -> AnimationObject:
	flag = f
	return self

func set_flag_after() -> AnimationObject:
	return set_flag(Flags.PlayAfterStep)

func set_flag_with() -> AnimationObject:
	return set_flag(Flags.PlayWithStep)

func set_flag_extend() -> AnimationObject:
	return set_flag(Flags.ExtendStep)

func has_flag(f: Flags) -> bool:
	return f == flag

func set_delay(d: float) -> AnimationObject:
	if d <= 0.0:
		push_error("Invalid Animation delay")
	delay = d
	return self

func set_min_duration(d: float) -> AnimationObject:
	if d < 0.0:
		push_error("Invalid Min Duration")
	min_duration = d
	return self

func set_max_duration(d: float) -> AnimationObject:
	if d < 0.0:
		push_error("Invalid Max Duration")
	if d == 0.0:
		d = 0.01
	max_duration = d
	return self

func set_duration(d: float) -> AnimationObject:
	set_min_duration(d)
	set_max_duration(d)
	return self

var _add_wait_ticket_to_args := false
func add_wait_ticket_to_args() -> AnimationCallable:
	assert(self is AnimationCallable)
	_add_wait_ticket_to_args = true
	return self

func set_seperate_queue(queue_id := "x") -> AnimationObject:
	seperate_queue_id = queue_id
	return self

################
## Debug Info ##
################

func _to_string() -> String:
	return "Anim: Abstract Animation Object"

var stack_trace: Array[Dictionary]
var print_stack_trace_lines: bool:
	set(x):
		print("--- Stack for %s ---" % self._to_string())
		for line in Utility.get_stack_trace_lines(stack_trace, [
			"_build_stack_trace", "_init", "AnimationUtility"
		]): print(line)

func _build_stack_trace() -> void:
	if not DebugInfo.ACTIVE:
		return
	stack_trace = get_stack()
