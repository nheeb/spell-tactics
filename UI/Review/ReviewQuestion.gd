class_name ReviewQuestion extends Container

enum TYPE {
	Text,
	MultipleChoice
}

var target_property: String
var target_index # When the property is Array or dict
var question_text: String
var question_type: TYPE

var choices: Array[String]
var checkboxes: Array[CheckBox]

func get_answer():
	match question_type:
		TYPE.Text:
			return $TextEdit.text
		TYPE.MultipleChoice:
			var answers := []
			for cb in checkboxes:
				if cb.button_pressed:
					answers.append(cb.text)
			return ";".join(answers)

func fill_property(review: CombatReview) -> void:
	var answer = get_answer()
	var current_value = review.get(target_property)
	if current_value is Array or current_value is Dictionary:
		current_value[target_index] = answer
	else:
		review.set(target_property, answer)

func setup_text(_target_property: String, _question_text: String) -> void:
	question_type = TYPE.Text
	target_property = _target_property
	question_text = _question_text
	_setup()

func setup_multiple_choice(_target_property: String, _question_text: String, _choices: Array[String]) -> void:
	question_type = TYPE.MultipleChoice
	target_property = _target_property
	question_text = _question_text
	choices = _choices
	_setup()

func _setup() -> void:
	%TextEdit.visible = false
	%HandCard2D.visible = false
	%QuestionLabel.text = question_text
	match question_type:
		TYPE.Text:
			%TextEdit.visible = true
		TYPE.MultipleChoice:
			checkboxes.clear()
			for c in choices:
				var cb = CheckBox.new()
				checkboxes.append(cb)
				%QuestionBody.add_child(cb)
				cb.text = c
