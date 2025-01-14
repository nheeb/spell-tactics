class_name AnimationUtility extends CombatUtility


#########################################
## Shortcut Functions (only use those) ##
#########################################

func call_method(ref: Object, method: String, parameters: Array = []) -> AnimationCallable:
	var _callable = ref.get(method) as Callable
	if _callable:
		if parameters:
			return callable(_callable.bindv(parameters))
		else:
			return callable(_callable)
	push_error("Animation Call Method: Object has no such method")
	return callable(func(): pass)

func wait(time: float = 0.0) -> AnimationWait:
	var a = AnimationWait.new(time)
	add_animation_object(a)
	return a

func signal_emit(ref: Object, signal_name: String) -> AnimationSignalEmit:
	var a = AnimationSignalEmit.new(ref, signal_name)
	add_animation_object(a)
	return a

func property(ref: Object, prop: String, value) -> AnimationProperty:
	var a = AnimationProperty.new(ref, prop, value)
	add_animation_object(a)
	return a

static var callables = 0
func callable(_callable: Callable) -> AnimationCallable:
	var a = AnimationCallable.new(_callable)
	add_animation_object(a)
	return a

func effect(_effect_scene: PackedScene, target: Object, _setup_properties := {}) -> AnimationEffect:
	if target is CombatObject:
		target = target.node3d
	assert(target is Node3D)
	var a = AnimationEffect.new(_effect_scene, target, _setup_properties)
	add_animation_object(a)
	return a

func add_staying_effect(_effect_scene: PackedScene, target: Object, id: String,_setup_properties := {}) -> AnimationStayingEffect:
	if target is CombatObject:
		target = target.node3d
	assert(target is VisualEntity or target is Tile3D, "target has a weird type")
	var a = AnimationStayingEffect.new(_effect_scene, target, id, _setup_properties)
	add_animation_object(a)
	return a

func remove_staying_effect(target: Object, id: String) -> AnimationCallable:
	if target is CombatObject:
		target = target.node3d
	assert(target is VisualEntity or target is Tile3D, "target has a weird type")
	return call_method(target, "remove_visual_effect", [id])

func wait_for_signal(_obj: Object, _signal_name: String) -> AnimationWaitForSignal:
	var a = AnimationWaitForSignal.new(_obj, _signal_name)
	add_animation_object(a)
	return a

func say(target: Object, text: String, params := {}) -> AnimationEffect:
	params["text"] = text
	return effect(VFX.SAY_EFFECT, target, params)
	## Quick Paste: combat.animation.say(target, "", {"color": Color., "font_size": 64})

func camera_set_player_input(enabled: bool) -> AnimationProperty:
	return property(combat.camera, "player_input_enabled", enabled)

func camera_follow(target) -> AnimationProperty:
	if target is CombatObject:
		target = target.node3d
	return property(combat.camera, "follow_target", target)

func camera_unfollow() -> AnimationProperty:
	return property(combat.camera, "follow_target", null)

func camera_reach(target) -> AnimationObject:
	if target is CombatObject:
		target = target.node3d
	assert(target)
	var animations : Array[AnimationObject] = []
	animations.append(property(combat.camera, "follow_target", target))
	animations.append(callable(combat.camera.follow_blocker.block))
	animations.append(property(combat.camera, "just_reach_target", true).set_flag(AnimationObject.Flags.PlayWithStep))
	animations.append(wait_for_signal(combat.camera, "target_reached").set_flag(AnimationObject.Flags.ExtendStep))
	return reappend_as_subqueue(animations)

func update_hp(ent: Entity) -> AnimationObject:
	var anims := []
	if ent.visual_entity.health_bar:
		anims.append(call_method(
			ent.visual_entity.health_bar, "update_hp", [ent.hp, ent.max_hp, ent.armor]
		))
		if not ent.type.always_show_hp:
			anims.push_front(show(ent.visual_entity.health_bar).set_duration(.2))
			anims.push_back(hide(ent.visual_entity.health_bar).set_duration(.2))
		return reappend_as_subqueue(anims)
	push_warning("Animation update hp: No HealthBar3D for ent %s" % ent)
	return wait()

func show(target) -> AnimationProperty:
	if target is CombatObject:
		target = target.node3d
	assert(target is Node)
	return property(target, "visible", true)

func hide(target) -> AnimationProperty:
	if target is CombatObject:
		target = target.node3d
	assert(target is Node)
	return property(target, "visible", false)

func combat_choice(activity: CombatChoiceActivity) -> AnimationCombatChoice:
	var a = AnimationCombatChoice.new(activity)
	add_animation_object(a)
	return a

#######################################
## Methods for organizing animations ##
#######################################-

func reappend_as_subqueue(_anims: Array) -> AnimationSubQueue:
	var anims: Array[AnimationObject] = get_flat_animation_array(_anims)
	for anim in anims:
		raw_animation_queue.erase(anim)
	var a = AnimationSubQueue.new(anims)
	add_animation_object(a)
	return a

func reappend_as_array(_anims: Array) -> Array[AnimationObject]:
	var anims: Array[AnimationObject] = get_flat_animation_array(_anims)
	for anim in anims:
		raw_animation_queue.erase(anim)
	for anim in anims:
		add_animation_object(anim)
	return anims

func get_flat_animation_array(anims) -> Array[AnimationObject]:
	var anim_array: Array[AnimationObject] = []
	if anims is AnimationObject:
		anim_array.append(anims)
	elif anims is Array:
		for a in anims:
			if a is AnimationObject:
				anim_array.append(a)
			elif a is Array:
				anim_array.append_array(get_flat_animation_array(a))
	else:
		push_error("No array or animobj given to flatten")
	return anim_array

## Record is an easy way to get the last X AnimationObjects that were added to the queue
func record_start(record_id := "") -> AnimationWait:
	return wait().set_record_id(record_id).set_flag_with()

## Returns all AnimationObjects that were added since the record with given id was started
func record_finish(record_id := "") -> Array[AnimationObject]:
	var record_object := Utility.array_get_first_filtered_value(
		Utility.array_reversed(raw_animation_queue),
		func (a: AnimationObject):
			if a is AnimationWait:
				return a.record_id == record_id
			return false
	) as AnimationWait
	if not record_object:
		push_warning("No animation record found for id %s" % record_id)
		return []
	var index := raw_animation_queue.find(record_object)
	var recorded_animations := raw_animation_queue.slice(index + 1)
	raw_animation_queue.erase(record_object)
	return recorded_animations

func record_finish_as_subqueue(record_id := "") -> AnimationSubQueue:
	return reappend_as_subqueue(record_finish(record_id))

##########################################
## Internal Functions (don't use those) ##
##########################################

const PROCESS_PER_FRAME = 10

signal animation_queues_empty
signal animation_process

var raw_animation_queue: Array[AnimationObject]
var currently_playing_queues: Array[AnimationQueue]
var currently_queued_queues: Array[AnimationQueue]

func add_animation_object(a: AnimationObject) -> void:
	a.setup(combat)
	raw_animation_queue.append(a)

func play_animation_queue() -> void:
	if raw_animation_queue:
		var aqs := AnimationQueue.from_raw_array(combat, raw_animation_queue.duplicate())
		raw_animation_queue.clear()
		currently_queued_queues.append_array(aqs)
		_animation_queue_process()

func play_single_queue(aq: AnimationQueue):
	currently_playing_queues.append(aq)
	aq.play()
	await aq.queue_finished
	currently_playing_queues.erase(aq)
	if not is_playing() and currently_queued_queues.is_empty() and raw_animation_queue.is_empty():
			animation_queues_empty.emit()
			VisualTime.visual_time_scale = 1.0
			VisualTime.current_speed_idx = 0

func is_playing() -> bool:
	return not currently_playing_queues.is_empty()

func get_playing_ids() -> Array:
	return Utility.array_unique(currently_playing_queues.map(
		func (aq: AnimationQueue): return aq.id
	))

func _process(delta: float) -> void:
	for i in range(PROCESS_PER_FRAME):
		_animation_queue_process()

func _animation_queue_process():
	animation_process.emit()
	if currently_queued_queues:
		var playing_ids := get_playing_ids()
		var queues_to_start := []
		for queue in currently_queued_queues:
			if queue.id not in playing_ids:
				queues_to_start.append(queue)
				playing_ids.append(queue.id)
		for queue in queues_to_start:
			currently_queued_queues.erase(queue)
			play_single_queue(queue)
