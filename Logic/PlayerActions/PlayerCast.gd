class_name PlayerCast extends PlayerAction

var spell : Spell
var payment : Array[Game.Energy]

func _init(_spell: Spell, _payment: Array[Game.Energy]) -> void:
	spell = _spell
	payment = _payment
	action_string = "Cast Spell %s with payment %s" % [spell.type.internal_name, Utility.energy_to_string(payment)]

func is_valid() -> bool:
	if Game.combat.current_phase != Combat.RoundPhase.Spell:
		return false
	return spell.logic.is_all_valid(payment)

func execute() -> void:
	spell.logic.cast(payment)
