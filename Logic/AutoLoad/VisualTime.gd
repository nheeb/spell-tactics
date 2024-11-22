extends Node

var visual_time_scale := 1.0:
	set(factor):
		var change_factor := factor / visual_time_scale
		visual_time_scale = factor
		for tween in tweens:
			tween.set_speed_scale(visual_time_scale)
		for ap in animation_players:
			if is_instance_valid(ap):
				ap.speed_scale *= change_factor


signal visual_process(delta: float)

var timers : Array[VisualTimer] = []
var tweens : Array[Tween] = []
var animation_players : Array[AnimationPlayer] = []

var visual_global_time := 0.0

class VisualTimer extends Object:
	var time_left: float
	var stopwatch: bool
	
	signal timeout
	
	func _init(t: float, _stopwatch := false) -> void:
		time_left = t
		stopwatch = _stopwatch
	
	func process(delta: float):
		if stopwatch:
			time_left += delta
		else:
			time_left -= delta
		if time_left <= 0.0:
			timeout.emit()

class VisualProgress extends RefCounted:
	var _progress := 0.0
	var _target := 0.0
	var _active := false
	var _speed := 1.0
	var base_speed := 1.0
	signal progress_change(progress: float)
	func _init(start := 0.0, speed := 1.0) -> void:
		_progress = start
		base_speed = speed
		VisualTime.visual_process.connect(_process)
	func connect_to(callable: Callable, first_emit := true):
		progress_change.connect(callable)
		if first_emit:
			set_progress(_progress)
	func set_progress(progress: float):
		_progress = progress
		progress_change.emit(_progress)
	func reach(target: float, duration := 0.0):
		if target != _progress:
			_target = target
			_active = true
			if duration > 0.0:
				_speed = abs(_target - _progress) / duration
			else:
				_speed = base_speed
	func _process(delta: float):
		if _active:
			if _progress == _target:
				_active = false
			else:
				delta = delta * VisualTime.visual_time_scale
				var s: float = sign(_target - _progress)
				var new_progress := _progress + s * delta * _speed
				if s != sign(_target - new_progress):
					new_progress = _target
				set_progress(new_progress)

func new_timer(duration: float, stopwatch := false) -> VisualTimer:
	var new_timerx = VisualTimer.new(duration, stopwatch)
	timers.append(new_timerx)
	new_timerx.timeout.connect(destroy_timer.bind(new_timerx), CONNECT_DEFERRED)
	return new_timerx

func destroy_timer(timer: VisualTimer) -> void:
	timers.erase(timer)
	timer.free()

func new_tween() -> Tween:
	var new_tweenx := get_tree().create_tween()
	new_tweenx.set_speed_scale(visual_time_scale)
	tweens.append(new_tweenx)
	new_tweenx.finished.connect(destroy_tween.bind(new_tweenx), CONNECT_DEFERRED)
	return new_tweenx

func destroy_tween(tween: Tween) -> void:
	tweens.erase(tween)
	#tween.free()

func new_progress(start := 0.0, speed := 1.0) -> VisualProgress:
	var progress := VisualProgress.new(start, speed)
	return progress

func connect_animation_player(ap: AnimationPlayer) -> void:
	if ap == null:
		return
	if not ap in animation_players:
		animation_players.append(ap)
		ap.speed_scale += visual_time_scale

func disconnect_animation_player(ap: AnimationPlayer) -> void:
	if ap in animation_players:
		animation_players.erase(ap)

signal changed_speed(speed_index)
const SPEED_SETTINGS = [1.0, 3.0, 10.0]
var current_speed_idx: int = 0:
	set(c):
		if c != current_speed_idx:
			changed_speed.emit(c)
		current_speed_idx = c

func _process(delta: float) -> void:
	var animation_speed = 1.0
	if Input.is_action_just_pressed("cycle_animation_speed"):
		current_speed_idx = (current_speed_idx + 1) % len(SPEED_SETTINGS)
		animation_speed = SPEED_SETTINGS[current_speed_idx]
		#changed_speed.emit(current_speed_idx)
		#print("Set speed to ", animation_speed)
		visual_time_scale = animation_speed
		
	#if animation_speed != visual_time_scale:
		#visual_time_scale = animation_speed
	
	var fixed_delta := delta * visual_time_scale
	visual_global_time += fixed_delta
	visual_process.emit(fixed_delta)
	for timer in timers:
		timer.process(fixed_delta)
