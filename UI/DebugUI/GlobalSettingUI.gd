extends HBoxContainer

var entry: DebugInfo.GlobalSettingsEntry

func _ready() -> void:
	%HSlider.visible = false

func setup(_entry: DebugInfo.GlobalSettingsEntry):
	entry = _entry
	%AttrName.text = entry.attr_name
	%LineEdit.text = entry.text
	
	if entry.use_range and not %HSlider.visible:
		%HSlider.visible = true
		%HSlider.min_value = entry.range_start
		%HSlider.max_value = entry.range_end
		if entry.get_value() != null:
			%HSlider.value = entry.get_value()
		else:
			%HSlider.value = entry.range_start
		%HSlider.step = abs(entry.range_end - entry.range_start) / 100.0
		if not %HSlider.value_changed.is_connected(slider_set):
			%HSlider.value_changed.connect(slider_set)
		await VisualTime.visual_process
		refresh()
	elif entry.use_range:
		if entry.get_value() != null:
			%HSlider.value = entry.get_value()

func slider_set(value):
	entry.set_value(value)
	refresh()

func refresh():
	setup(entry)

func _on_refresh_pressed() -> void:
	refresh()

func _on_change_pressed() -> void:
	entry.set_value(%LineEdit.text)
	refresh()

func _on_reset_pressed() -> void:
	entry.reset()
	refresh()
