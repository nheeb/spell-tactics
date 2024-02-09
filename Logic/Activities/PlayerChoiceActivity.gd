class_name PlayerChoiceActivity extends Activity

var question: String
var choices: Array
var choices_strings: Array

signal resolved(result)

func _init(_question: String, _choices: Array, _choices_strings: Array = []) -> void:
	question = _question
	choices = _choices
	choices_strings = _choices_strings
	assert(choices)
	if choices_strings:
		assert(choices.size() == choices_strings.size())
