class_name PlayerCast extends PlayerAction

var spell : Spell
var payment : EnergyStack

func _init(_spell: Spell, _payment: EnergyStack) -> void:
	spell = _spell
	payment = _payment
	action_string = "Cast Spell %s with payment %s" % [spell.type.internal_name, payment.to_string()]
	printerr("Using deprecated PlayerAction %s" % action_string)

func is_valid(combat: Combat) -> bool:
	if combat.current_phase != Combat.RoundPhase.Spell:
		return false
	return spell.logic.is_all_valid(payment)

func execute(combat: Combat) -> void:
	spell.logic.cast(payment)
	combat.animation.callback(combat.player.visual_entity, "stop_casting")
	combat.spell_casted_successfully.emit(spell.get_reference())
