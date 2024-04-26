class_name FixedLabel extends Label

func fix_me() -> void:
	custom_minimum_size.y = 10 + get_line_count() * get_line_height()

func set_text_fixed(_text: String) -> void:
	text = _text
	await VisualTime.visual_process
	fix_me()
	
