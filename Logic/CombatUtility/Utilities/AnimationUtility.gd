class_name AnimationUtility extends CombatUtility

const SAY_EFFECT = preload("res://Effects/SayEffect.tscn")

signal animation_queue_empty

var animation_queue: Array[AnimationObject]
var currently_playing_queues: Array[AnimationQueue]

########################################
## Wrapper Functions (only use those) ##
########################################

func callback(ref: Object, method: String, parameters: Array = []) -> AnimationCallback:
	var a = AnimationCallback.new(ref, method, parameters)
	add_animation_object(a)
	return a

func wait(time: float) -> AnimationWait:
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

func callable(_callable: Callable) -> AnimationCallable:
	var a = AnimationCallable.new(_callable)
	add_animation_object(a)
	return a

func effect(_effect_scene: PackedScene, target: Node3D,_setup_properties := {}) -> AnimationEffect:
	var a = AnimationEffect.new(_effect_scene, target, _setup_properties)
	add_animation_object(a)
	return a

func add_staying_effect(_effect_scene: PackedScene, target: VisualEntity, id: String,_setup_properties := {}) -> AnimationStayingEffect:
	var a = AnimationStayingEffect.new(_effect_scene, target, id, _setup_properties)
	add_animation_object(a)
	return a

func remove_staying_effect(target: VisualEntity, id: String) -> AnimationCallback:
	return callback(target, "remove_visual_effect", [id])

func wait_for_signal(_obj: Object, _signal_name: String) -> AnimationWaitForSignal:
	var a = AnimationWaitForSignal.new(_obj, _signal_name)
	add_animation_object(a)
	return a

func say(target: Node3D, text: String, params := {}) -> AnimationEffect:
	params["text"] = text
	return effect(SAY_EFFECT, target, params)
	## Quick Paste: combat.animation.say(target, "", {"color": Color., "font_size": 64})

func camera_set_player_input(enabled: bool) -> AnimationProperty:
	return property(combat.camera, "player_input_enabled", enabled)

func camera_follow(target: Node3D) -> AnimationProperty:
	return property(combat.camera, "follow_target", target)

func camera_unfollow() -> AnimationProperty:
	return property(combat.camera, "follow_target", null)

func camera_reach(target: Node3D) -> AnimationObject:
	var animations : Array[AnimationObject] = []
	animations.append(property(combat.camera, "follow_target", target))
	animations.append(property(combat.camera, "just_reach_target", true).set_flag(AnimationObject.Flags.PlayWithStep))
	animations.append(wait_for_signal(combat.camera, "target_reached").set_flag(AnimationObject.Flags.ExtendStep))
	return reappend_as_subqueue(animations)

func update_hp(ent: HPEntity) -> AnimationObject:
	if ent.visual_entity.has_node("HealthBar3D"):
		return callback(ent.visual_entity.get_node("HealthBar3D"), "update_hp", [ent.hp, ent.type.max_hp, ent.armor]).set_flag_with()
	elif ent.visual_entity.has_node("HPLabel"):
		if ent.armor:
			return property(ent.visual_entity.get_node("HPLabel"), "text", "%s [+%s] / %s" % [ent.hp, ent.armor, ent.type.max_hp])
		else:
			return property(ent.visual_entity.get_node("HPLabel"), "text", "%s / %s" % [ent.hp, ent.type.max_hp])

	push_error("Neither HPLabel nor HealthBar3D for ent %s" % ent)
	return null

func show(node: Node3D) -> AnimationProperty:
	return property(node, "visible", true)

func hide(node: Node3D) -> AnimationProperty:
	return property(node, "visible", false)

func combat_choice(activity: CombatChoiceActivity) -> AnimationCombatChoice:
	var a = AnimationCombatChoice.new(activity)
	add_animation_object(a)
	return a

func reappend_as_subqueue(_anims: Array) -> AnimationSubQueue:
	var anims: Array[AnimationObject] = get_flat_animation_array(_anims)
	for anim in anims:
		animation_queue.erase(anim)
	var a = AnimationSubQueue.new(anims)
	add_animation_object(a)
	return a

func reappend_as_array(_anims: Array) -> Array[AnimationObject]:
	var anims: Array[AnimationObject] = get_flat_animation_array(_anims)
	for anim in anims:
		animation_queue.erase(anim)
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
	

#######################################
## Logic Functions (don't use those) ##
#######################################

func add_animation_object(a: AnimationObject) -> void:
	animation_queue.append(a)

func play_animation_queue() -> void:
	if currently_playing_queues.is_empty():
		while not animation_queue.is_empty():
			var aq := AnimationQueue.new(animation_queue.duplicate())
			currently_playing_queues.append(aq)
			animation_queue.clear()
			aq.play(combat)
			await aq.queue_finished
			currently_playing_queues.erase(aq)
		animation_queue_empty.emit()
		VisualTime.visual_time_scale = 1.0
		VisualTime.current_speed_idx = 0

func is_playing() -> bool:
	return not currently_playing_queues.is_empty()
