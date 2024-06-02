extends Control

@onready var ticks = [%SpeedTick0, %SpeedTick1, %SpeedTick2]

@export var active = false:
	set(a):
		if not active and a:
			$AnimationPlayer.play("fade_in")
		if active and not a:
			$AnimationPlayer.play("fade_out")
		active = a
var speed_idx: int = 0


func _enter_tree() -> void:
	# register itself to VisualTime
	VisualTime.changed_speed.connect(set_speed)
	
func _ready() -> void:
	set_speed(0)
	

const ON_MATERIAL = preload("res://Shaders/UI/SpeedTickOn.tres")
const OFF_MATERIAL = preload("res://Shaders/UI/SpeedTickOff.tres")
func set_speed(_speed_idx: int):
	print("Set speed to ", _speed_idx)
	self.speed_idx = _speed_idx
	if speed_idx > 0:
		self.active = true
	$FadeOutTimer.start()

	match speed_idx:
		0:
			ticks[0].material = ON_MATERIAL
			ticks[1].material = OFF_MATERIAL
			ticks[2].material = OFF_MATERIAL
		1:
			ticks[0].material = ON_MATERIAL
			ticks[1].material = ON_MATERIAL
			ticks[2].material = OFF_MATERIAL
		2:
			ticks[0].material = ON_MATERIAL
			ticks[1].material = ON_MATERIAL
			ticks[2].material = ON_MATERIAL
		_:
			printerr("Invalid speed_idx passed in UI set_speed().")


func _on_fade_out_timer_timeout() -> void:
	if active and speed_idx == 0.0:
		self.active = false
