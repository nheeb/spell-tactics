class_name AnimationQueue extends RefCounted

signal queue_finished

var combat: Combat
var id: String
var animation_objects: Array[AnimationObject]
var animation_steps: Array[AnimationStep]
var current_step: AnimationStep
var currently_playing := false
var step_ready := true

static func from_raw_array(_combat: Combat, raw_queue: Array[AnimationObject]) -> Array[AnimationQueue]:
	var raw_queues: Dictionary = {} # {id (str) -> Array[AnimationObject]}
	var typed_array: Array[AnimationObject] = [] # Fuck you Godot, this is so CRINGE omg...
	# Let me at least type cast Arrays with '... as Array[AnimationObject]'.
	# But no you just ignore that and force me to write shitty code like that. Fuck you.
	for anim in raw_queue:
		raw_queues.get_or_add(anim._seperate_queue_id, typed_array.duplicate()).append(anim)
	var queue_objects: Array[AnimationQueue]
	for _id in raw_queues.keys():
		queue_objects.append(
			AnimationQueue.new(_combat, _id, raw_queues.get(_id, typed_array.duplicate()))
		)
	return queue_objects

func _init(_combat: Combat, _id: String, queue: Array[AnimationObject]) -> void:
	combat = _combat
	id = _id
	animation_objects = queue

func play() -> void:
	currently_playing = true
	await combat.animation.animation_process
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
			play_next_step()
			if not currently_playing:
				break
		else:
			await combat.animation.animation_process

func play_next_step() -> void:
	if animation_steps.is_empty():
		currently_playing = false
		queue_finished.emit()
	else:
		current_step = animation_steps.pop_front()
		current_step.play()
