extends CanvasLayer

var activity: CardChoiceActivity

func set_activity(_activity: CardChoiceActivity):
	self.activity = _activity
	setup()

func resolve(result: Variant):
	#ActivityManager.pop() will be done by the AnimationCombatChoice
	activity._resolve(result)

func on_view_removed() -> void:
	queue_free()

func setup():
	%Button.disabled = true
	activity.cards.start_choice(activity.count_min, activity.count_max)
	activity.cards.card_chosen.connect(on_card_chosen)
	if activity.count_min == activity.count_max:
		%Prompt.text = "Select %s cards!" % activity.count_min
	else:
		%Prompt.text = "Select %s - %s cards!" % [activity.count_min, activity.count_max]

func on_card_chosen(count: int):
	%Label.text = "(%s selected)" % count
	var submission_possible =   count >= activity.count_min \
							and count <= activity.count_max
	%Button.disabled = not submission_possible

func _on_button_pressed() -> void:
	resolve(activity.cards.end_choice_and_get_result())
