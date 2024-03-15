class_name PlayerChoiceActivity extends CombatChoiceActivity

var question: String
var choices: Array
var choices_strings: Array

## Creates the activity
func _init(_question: String, _choices: Array, _choices_strings: Array = []) -> void:
	question = _question
	choices = _choices
	choices_strings = _choices_strings
	assert(choices)
	if choices_strings:
		assert(choices.size() == choices_strings.size())
