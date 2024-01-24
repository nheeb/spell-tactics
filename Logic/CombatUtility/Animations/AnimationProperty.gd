class_name AnimationProperty extends AnimationObject

var reference: Object
var property: String
var value

func _init(_reference: Object, _property: String, _value):
	reference = _reference
	property = _property
	value = _value

func play(level: Level) -> void:
	if is_instance_valid(reference):
		reference.set(property, value)
		success = true
	animation_done_internally.emit()

func _to_string() -> String:
	return "Anim: Setting %s.%s = %s" % [reference, property, value]

