class_name AnimationUtility extends Node

const SAY_EFFECT = preload("res://Effects/SayEffect.tscn")

@onready var combat : Combat = get_parent().get_parent()

signal animation_queue_empty

var animation_queue: Array[AnimationObject]
var animation_steps: Array[AnimationStep]

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

func camera_set_player_input(enabled: bool) -> AnimationProperty:
	return property(combat.camera, "player_input_enabled", enabled)

func camera_follow(target: Node3D) -> AnimationProperty:
	return property(combat.camera, "follow_target", target)

func camera_unfollow() -> AnimationProperty:
	return property(combat.camera, "follow_target", null)

func camera_reach(target: Node3D) -> Array[AnimationObject]:
	var animations : Array[AnimationObject] = []
	animations.append(property(combat.camera, "follow_target", target))
	animations.append(property(combat.camera, "just_reach_target", true).set_flag(AnimationObject.Flags.PlayWithStep))
	animations.append(wait_for_signal(combat.camera, "target_reached").set_flag(AnimationObject.Flags.ExtendStep))
	return animations

func update_hp(ent: HPEntity) -> AnimationProperty:
	if ent.visual_entity.has_node("HPLabel"):
		if ent.armor:
			return property(ent.visual_entity.get_node("HPLabel"), "text", "%s [+%s] / %s" % [ent.hp, ent.armor, ent.type.max_hp])
		else:
			return property(ent.visual_entity.get_node("HPLabel"), "text", "%s / %s" % [ent.hp, ent.type.max_hp])
	else:
		return null

func show(node: Node3D) -> AnimationProperty:
	return property(node, "visible", true)

func hide(node: Node3D) -> AnimationProperty:
	return property(node, "visible", false)

#######################################
## Logic Functions (don't use those) ##
#######################################

func add_animation_object(a: AnimationObject) -> void:
	animation_queue.append(a)

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
			#print(a)
			a._play(level)
		if relevant_animations_to_do == 0:
			step_done.emit()
