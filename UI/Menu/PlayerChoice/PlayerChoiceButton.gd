class_name PlayerChoiceButton extends CenterContainer

signal clicked(value: Variant)

var value: Variant
var value_string: String

func setup(_value: Variant, _value_string := "") ->  void:
	value = _value
	if _value_string == "":
		value_string  = str(value)
	else:
		value_string = _value_string
	%Button.text = value_string

func _on_button_pressed() -> void:
	clicked.emit(value)
