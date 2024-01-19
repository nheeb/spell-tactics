class_name AnimationUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

signal animation_queue_empty

var animation_queue: Array[AnimationObject]
var animation_steps: Array[AnimationStep]

func callback(ref: Object, method: String, parameters: Array = []) -> AnimationCallback:
	var a = AnimationCallback.new(ref, method, parameters)
	animation_queue.append(a)
	return a

func wait(time: float) -> AnimationWait:
	var a = AnimationWait.new(time)
	animation_queue.append(a)
	return a

func signal_emit(ref: Object, signal_name: String) -> AnimationSignalEmit:
	var a = AnimationSignalEmit.new(ref, signal_name)
	animation_queue.append(a)
	return a

func play_animation_queue() -> void:
	animation_steps = [AnimationStep.new()]
	for animation in animation_queue:
		if animation.has_flag(AnimationObject.Flags.PlayAfterStep):
			animation_steps.append(AnimationStep.new())
		animation_steps[-1].animations.append(animation)
	for step in animation_steps:
		step.compile()
		step.step_done.connect(play_next_step, CONNECT_ONE_SHOT)
	play_next_step()

func play_next_step() -> void:
	if animation_steps.is_empty():
		animation_queue.clear()
		animation_queue_empty.emit()
	else:
		var step : AnimationStep = animation_steps.pop_front()
		step.play(combat.level)

class AnimationStep extends Object:
	signal step_done
	
	var animations : Array[AnimationObject] = []
	
	var relevant_animations_to_do := 0
	
	func relevant_animation_done() -> void:
		relevant_animations_to_do -= 1
		if relevant_animations_to_do <= 0:
			step_done.emit()
	
	func compile() -> void:
		for a in animations:
			if a.has_flag(AnimationObject.Flags.PlayAfterStep) or a.has_flag(AnimationObject.Flags.ExtendStep):
				relevant_animations_to_do += 1
				a.animation_done.connect(self.relevant_animation_done, CONNECT_ONE_SHOT)
	
	func play(level: Level) -> void:
		for a in animations:
			a.play(level)
		if relevant_animations_to_do == 0:
			step_done.emit()
