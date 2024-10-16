class_name AnimationProperty extends AnimationObject

var object: Object
var property: String
var value

func _init(_object: Object, _property: String, _value):
	object = _object
	property = _property
	value = _value
	_build_stack_trace()

func play(level: Level) -> void:
	if is_instance_valid(object):
		object.set(property, value)
	animation_done_internally.emit()

func _to_string() -> String:
	return "Anim: Setting %s.%s = %s" % [object, property, value]
