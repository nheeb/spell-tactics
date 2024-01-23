class_name AnimationEffect extends AnimationObject

var effect_scene: PackedScene
var position: Vector3
var setup_properties: Dictionary

## Time to wait
func _init(_effect_scene: PackedScene, _position: Vector3,_setup_properties := {}) -> void:
	effect_scene = _effect_scene
	position = _position
	setup_properties = _setup_properties

func set_property(prop_name: String, value) -> AnimationEffect:
	setup_properties[prop_name] = value
	return self

func play(level: Level):
	var effect = effect_scene.instantiate() as Node3D
	level.visual_effects.add_child(effect)
	effect.set("position", position)
	for prop in setup_properties:
		effect.set(prop, setup_properties[prop])
	if effect.has_signal("effect_done"):
		await effect.effect_done
	success = true
	animation_done.emit()

func _to_string() -> String:
	return "Anim: Create %s at %s with %s" % [effect_scene.resource_name, position, setup_properties]
