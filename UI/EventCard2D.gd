class_name EventCard2D extends Control

const ENTRY = preload("res://UI/EventCardEffectEntry.tscn")

func set_event(event: SpellType) -> void:
	%Title.text = "Event - %s" % event.pretty_name
	var effects := event.effect_text.split(";")
	for effect in effects:
		var sections = effect.split(":")
		var header: String
		var text: String
		if sections.size() == 2:
			header = sections[0].strip_edges()
			text = sections[1].strip_edges()
		else:
			header = "Effect"
			text = sections[0].strip_edges()
		var entry := ENTRY.instantiate()
		%EffectContainer.add_child(entry)
		entry.setup(header, text)
