class_name SpellTextLabel extends RichTextLabel


func _ready() -> void:
	pass
	
	
func _make_custom_tooltip(for_text: String) -> Object:
	var label = Label.new()
	label.text = "CUSTOM: " + for_text
	return label
	

const ENERGY_BB_CODE_TEMPLATE := "[img=66]res://Assets/Sprites/EnergyIconMasks/rendered/%s.png[/img]"
func preprocess_energy_orbs(spell_text: String) -> String:
	for energy_name in EnergyStack.EnergyType.keys():
		energy_name = energy_name.to_lower()
		var bb_code = ENERGY_BB_CODE_TEMPLATE % energy_name
		spell_text = spell_text.replace("[%s]" % energy_name, bb_code)
	return spell_text

func preprocess(spell_text: String) -> String: 
	spell_text = preprocess_energy_orbs(spell_text)
	spell_text = "[center]" + spell_text + "[/center]"
	return spell_text


func get_font_size():
	return get("theme_override_font_sizes/normal_font_size")

func set_font_size(_size: int):
	set("theme_override_font_sizes/normal_font_size", _size)
	set("theme_override_font_sizes/bold_font_size", _size)
	set("theme_override_font_sizes/italics_font_size", _size)

## choose automatic font size so its 3 lines maximum
func setup_font_size():
	await VisualTime.visual_process
	var first_with_4_lines := 0 
	while get_visible_line_count() > 4 and get_font_size() > 26:
		#if first_with_3_lines == 0 and get_visible_line_count() <= 5:
			#first_with_3_lines = get_font_size()
		set_font_size(get_font_size() - 2)
		await VisualTime.visual_process

	#if get_visible_line_count() > 3 and first_with_4_lines != 0:
		#set_font_size(first_with_3_lines)


func set_spell_text(spell_text: String):
	spell_text = preprocess(spell_text)
	setup_font_size()
	set_text(spell_text)
