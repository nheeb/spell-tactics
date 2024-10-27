class_name CombatEventInfo extends Control

func show_event(event: CombatEvent) -> void:
	%Title.set_text_fixed(event.type.pretty_name)
	%Effect.set_text_fixed(event.get_effect_text())
	%Fluff.set_text_fixed(event.type.fluff_text)
	show()
