class_name AnimationStayingEffect extends AnimationObject

var effect_scene: PackedScene
var target: Node3D
var setup_properties: Dictionary
var id: String

func _init(_effect_scene: PackedScene, _target: Node3D, _id: String, _setup_properties := {}) -> void:
	effect_scene = _effect_scene
	target = _target
	setup_properties = _setup_properties
	id = _id
	_build_stack_trace()

func set_property(prop_name: String, value) -> AnimationStayingEffect:
	setup_properties[prop_name] = value
	return self

func play(level: Level):
	if not target.has_method("add_visual_effect"):
		push_error("Target %s cannot take visual effects" % target)
		animation_done_internally.emit()
		return
	var effect = effect_scene.instantiate() as StayingVisualEffect
	target.add_visual_effect(id, effect)
	if is_instance_valid(target):
		effect.set("position", Vector3.ZERO)
	for prop in setup_properties:
		effect.set(prop, setup_properties[prop])
	
	if effect.has_signal("effect_done"):
		effect.effect_done.connect(func(): animation_done_internally.emit(),CONNECT_ONE_SHOT)
		if effect.has_method("effect_start"):
			effect.effect_start()
	else:
		if effect.has_method("effect_start"):
			effect.effect_start()
		animation_done_internally.emit()
	

func _to_string() -> String:
	if is_instance_valid(target):
		return "Anim: Create %s on %s with %s" % [effect_scene.resource_name, target, setup_properties]
	else:
		return "Anim: Effect without valid target"
