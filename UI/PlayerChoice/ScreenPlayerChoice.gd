extends CanvasLayer

const BUTTON = preload("res://UI/PlayerChoice/PlayerChoiceButton.tscn")
const MAX_COLUMS = 4

var activity: PlayerChoiceActivity

func set_activity(_activity: PlayerChoiceActivity):
	self.activity = _activity
	setup()

func resolve(result: Variant):
	ActivityManager.pop()
	activity.resolved.emit(result)

func on_view_removed() -> void:
	queue_free()

func setup():
	%QuestionLabel.text = activity.question
	var choice_count := activity.choices.size()
	%GridContainer.columns = min(choice_count, MAX_COLUMS)
	for i in range(choice_count):
		var btn : PlayerChoiceButton = BUTTON.instantiate() as PlayerChoiceButton
		if activity.choices_strings:
			btn.setup(activity.choices[i], activity.choices_strings[i])
		else:
			btn.setup(activity.choices[i])
		btn.clicked.connect(resolve)
		%GridContainer.add_child(btn)

func _on_hide_button_pressed() -> void:
	var vis: bool = not %Panel.visible
	%Panel.visible = vis
	%HideButton.text = "Hide" if vis else "Show"
