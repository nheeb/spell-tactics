extends EventSpellLogic

## Usable references:
## spell - Corresponding event
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the spell was created

func get_event_length() -> int:
	return 0

func event_effect(round_number: int) -> void:
	pass
