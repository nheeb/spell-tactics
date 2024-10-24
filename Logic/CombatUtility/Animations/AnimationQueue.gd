class_name AnimationQueue extends Object

var animation_objects: Array[AnimationObject]
var animation_steps: Array[AnimationStep]

var current_step: AnimationStep

var currently_playing := false
var step_ready := true

signal queue_finished

func _init(queue) -> void:
	animation_objects = queue

func play(combat: Combat) -> void:
	if not combat:
		push_error("Animation Queue played without combat?")
	currently_playing = true
	
	await VisualTime.visual_process
	
	if animation_objects.is_empty():
		queue_finished.emit()
		return
	
	animation_steps = [AnimationStep.new()]
	for animation in animation_objects:
		if animation.has_flag(AnimationObject.Flags.PlayAfterStep):
			animation_steps.append(AnimationStep.new())
		animation_steps[-1].animations.append(animation)
	for step in animation_steps:
		step.compile()
		step.step_done.connect(func(): step_ready = true, CONNECT_ONE_SHOT)
	
	while true:
		if step_ready:
			step_ready = false
			play_next_step(combat)
			if not currently_playing:
				break
		else:
			await VisualTime.visual_process

func play_next_step(combat: Combat) -> void:
	if animation_steps.is_empty():
		currently_playing = false
		queue_finished.emit()
	else:
		current_step = animation_steps.pop_front()
		current_step.play(combat.level)
