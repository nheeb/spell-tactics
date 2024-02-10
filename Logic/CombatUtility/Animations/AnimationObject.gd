class_name AnimationObject extends Object

## This is the abstract Animation Object

signal animation_done
signal animation_done_internally

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
		printerr("Invalid Animation delay")
	delay = d
	return self

func set_min_duration(d: float) -> AnimationObject:
	if d <= 0.0:
		printerr("Invalid Min Duration")
	min_duration = d
	return self

func set_max_duration(d: float) -> AnimationObject:
	if d < 0.0:
		printerr("Invalid Max Duration")
	if d == 0.0:
		d = 0.01
	max_duration = d
	return self

func set_duration(d: float) -> AnimationObject:
	set_min_duration(d)
	set_max_duration(d)
	return self

func _play(level: Level) -> void:
	#if animation_done_internally.is_connected(internal_animation_done):
		#print("ERROR")
	
	DebugInfo.current_animations.append(self)
	
	animation_done_internally.connect(internal_animation_done)
	await VisualTime.visual_process
	if delay > 0.0:
		await VisualTime.new_timer(delay).timeout
	global_start_time = VisualTime.visual_global_time
	if max_duration != 0.0:
		if max_duration < max(min_duration, 0.0) :
			printerr("AnimationObject: Invalid max / min durations")
		VisualTime.new_timer(max_duration).timeout.connect(internal_animation_done)
	play(level)

## Override this to set what the animation does. Always emit animation_done_internally at the end
func play(level: Level) -> void:
	pass

func internal_animation_done() -> void:
	var ellapsed_time : float = abs(VisualTime.visual_global_time - global_start_time)
	if ellapsed_time < min_duration:
		await VisualTime.new_timer(min_duration - ellapsed_time).timeout
	DebugInfo.current_animations.erase(self)
	animation_done.emit()

func _to_string() -> String:
	return "Anim: Abstract Animation Object"
