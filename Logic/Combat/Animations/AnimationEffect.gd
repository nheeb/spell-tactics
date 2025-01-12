class_name AnimationEffect extends AnimationObject

var effect_scene: PackedScene
var target: Node3D
var setup_properties: Dictionary

func _init(_effect_scene: PackedScene, _target: Node3D, _setup_properties := {}) -> void:
	effect_scene = _effect_scene
	target = _target
	setup_properties = _setup_properties

func set_property(prop_name: String, value) -> AnimationEffect:
	setup_properties[prop_name] = value
	return self

func play():
	var effect = effect_scene.instantiate() as Node3D
	level.visual_effects.add_child(effect)
	if is_instance_valid(target):
		effect.set("position", target.position)
	for prop in setup_properties:
		effect.set(prop, setup_properties[prop])
		assert(
			effect.get(prop) == setup_properties[prop],
			"Effect property wasn't set properly."
		)
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
		return "Anim: Create %s at %s with %s" % [effect_scene.resource_name, target.position, setup_properties]
	else: 
		return "Anim: Effect without valid target"
