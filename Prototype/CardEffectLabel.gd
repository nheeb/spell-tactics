extends RichTextLabel


func _ready() -> void:
	pass
	
	
func _make_custom_tooltip(for_text: String) -> Object:
	var label = Label.new()
	label.text = "CUSTOM: " + for_text
	return label
	



	
func preprocess(effect_text: String): 
	pass
