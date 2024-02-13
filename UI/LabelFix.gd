class_name FixedLabel extends Label

func fix_me() -> void:
	custom_minimum_size.y = 10 + get_line_count() * get_line_height()
