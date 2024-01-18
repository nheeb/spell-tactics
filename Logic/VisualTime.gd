extends Node

var visual_time_scale := 1.0:
	set(factor):
		var change_factor := factor / visual_time_scale
		visual_time_scale = factor
		for tween in tweens:
			tween.set_speed_scale(visual_time_scale)
		for ap in animation_players:
			ap.speed_scale *= change_factor

signal visual_process(delta: float)

var timers : Array[VisualTimer] = []
var tweens : Array[Tween] = []
var animation_players : Array[AnimationPlayer] = []

class VisualTimer extends Object:
	var time_left: float
	
	signal timeout
	
	func _init(t: float) -> void:
		time_left = t
	
	func process(delta: float):
		time_left -= delta
		if time_left <= 0.0:
			timeout.emit()
	
func new_timer(duration: float) -> VisualTimer:
	var new_timer = VisualTimer.new(duration)
	timers.append(new_timer)
	new_timer.timeout.connect(destroy_timer.bind(new_timer), CONNECT_DEFERRED)
	return new_timer

func destroy_timer(timer: VisualTimer) -> void:
	timers.erase(timer)
	timer.free()

func new_tween() -> Tween:
	var new_tween := get_tree().create_tween()
	new_tween.set_speed_scale(visual_time_scale)
	tweens.append(new_tween)
	new_tween.finished.connect(destroy_tween.bind(new_tween), CONNECT_DEFERRED)
	return new_tween

func destroy_tween(tween: Tween) -> void:
	tweens.erase(tween)
	tween.free()

func connect_animation_player(ap: AnimationPlayer) -> void:
	if not ap in animation_players:
		animation_players.append(ap)
		ap.speed_scale += visual_time_scale

func disconnect_animation_player(ap: AnimationPlayer) -> void:
	if ap in animation_players:
		animation_players.erase(ap)

func _process(delta: float) -> void:
	var fixed_delta := delta * visual_time_scale
	visual_process.emit(fixed_delta)
	for timer in timers:
		timer.process(fixed_delta)

