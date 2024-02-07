class_name ReviewQuestion extends VBoxContainer

enum TYPE {
	Text,
	MultipleChoice,
	NumberSlider
}

var target_property: String
var target_index # When the property is Array or dict
var question_text: String
var question_type: TYPE

var choices: Array[String]
var checkboxes: Array[CheckBox]

func get_answer() -> String:
	match question_type:
		TYPE.Text:
			return %TextEdit.text
		TYPE.MultipleChoice:
			var answers := []
			for cb in checkboxes:
				if cb.button_pressed:
					answers.append(cb.text)
			var answer := ";".join(answers)
			if %CustomCB.button_pressed:
				answer = answer + ";%s" % %CustomOptionText.text
			return answer
		TYPE.NumberSlider:
			return str(%HSlider.value)
	return "Error: No question type"

func fill_property(review: CombatReview) -> void:
	var answer = get_answer()
	var current_value = review.get(target_property)
	if current_value is Array or current_value is Dictionary:
		current_value[target_index] = answer
	else:
		review.set(target_property, answer)

func set_target_index(_target_index) -> ReviewQuestion:
	target_index = _target_index
	return self

func setup_text(_target_property: String, _question_text: String) -> ReviewQuestion:
	question_type = TYPE.Text
	target_property = _target_property
	question_text = _question_text
	_setup()
	return self

func setup_multiple_choice(_target_property: String, _question_text: String, _choices: Array[String]) -> ReviewQuestion:
	question_type = TYPE.MultipleChoice
	target_property = _target_property
	question_text = _question_text
	choices = _choices
	_setup()
	return self

func setup_number_slider(_target_property: String, _question_text: String) -> ReviewQuestion:
	question_type = TYPE.NumberSlider
	target_property = _target_property
	question_text = _question_text
	_setup()
	return self

func _setup() -> void:
	%TextEdit.visible = false
	%HandCard2D.visible = false
	%SliderContainer.visible = false
	%TextureRect.visible = false
	%QuestionLabel.text = question_text
	%CustomOption.visible = false
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
			%CustomOption.visible = true
			%QuestionBody.move_child(%CustomOption, -1)
		TYPE.NumberSlider:
			%SliderContainer.visible = true

func _on_custom_cb_toggled(toggled_on: bool) -> void:
	%CustomOptionText.editable = toggled_on

func set_spell(spell: SpellType) -> ReviewQuestion:
	%HandCard2D.set_spell_type(spell)
	%HandCard2D.visible = true
	return self

func set_image(texture) -> ReviewQuestion:
	if texture:
		%TextureRect.texture = texture
		%TextureRect.visible = true
	return self


func _on_h_slider_value_changed(value: float) -> void:
	%SliderNumber.text = str(value)
