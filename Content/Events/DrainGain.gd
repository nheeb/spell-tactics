extends CombatEventLogic

var drain: Active = null:
	get:
		if drain == null:
			drain = combat.castables.get_active_from_name("drain")
		return drain

# actually [1, 3, 6] but ActivesUI can't handle it atm
const DEFAULT_GAIN_PATTERN = [2, 5]

## Contains the rounds where drain usage is increased
var gain_pattern: Array

func _on_activate() -> void:
	gain_pattern = event.data.get("gain_pattern", DEFAULT_GAIN_PATTERN)
	gain_pattern = Utility.array_unique(gain_pattern)
	gain_pattern.sort()

func _on_advance(round_number: int) -> void:
	if round_number in gain_pattern:
		drain.set_limitation_max_uses(drain.get_limitation_max_uses() + 1)
		combat.animation.say(combat.player.visual_entity, "+1 Drain Usage")
		gain_pattern.erase(round_number)
	if gain_pattern.is_empty():
		event.finish()
	else:
		event.data["extra_text"] = \
			"\nRounds until drain usage is increased: %s" % \
			str(gain_pattern.front() - round_number)
