class_name EnergyStack extends Resource

enum EnergyType {
	Life = 1,
	Decay = 2,
	Matter = 3,
	Harmony = 4,
	Flow = 5,
	Spectral = 6,
	Any = 7,
}

@export var stack : Array[EnergyType] = []

## Returns an EnergyStack with possible payment arrangement if possible or null if not
func get_possible_payment(cost_stack: EnergyStack) -> EnergyStack:
	stack.sort()
	cost_stack.sort()
	var bank := stack.duplicate()
	var cost := cost_stack.stack.duplicate()
	var possible_payment : Array[EnergyType] = []
	for e in cost:
		if e != EnergyType.Any:
			if e in bank:
				possible_payment.append(e)
				bank.erase(e)
			else:
				return null
		else:
			if not bank.is_empty():
				possible_payment.append(bank.pop_front())
			else:
				return null
	return EnergyStack.new(possible_payment)

func sort() -> void:
	stack.sort()

## Applies a payment (reducing the energy by the exact energies in that payment)
func apply_payment(payment: EnergyStack) -> void:
	for e in payment.stack:
		if e in stack:
			stack.erase(e)
		else:
			printerr("Non existing energy was payed.")

const ENERGY_TO_LETTER = {
	EnergyType.Any: "X",
	EnergyType.Life: "L",
	EnergyType.Decay: "D",
	EnergyType.Matter: "M",
	EnergyType.Harmony: "H",
	EnergyType.Flow: "F",
	EnergyType.Spectral: "S",
}

const LETTER_TO_ENERGY = {
	"X": EnergyType.Any,
	"L": EnergyType.Life,
	"D": EnergyType.Decay,
	"M": EnergyType.Matter,
	"H": EnergyType.Harmony,
	"F": EnergyType.Flow,
	"S": EnergyType.Spectral,
}

static func energy_to_string(energy_stack: EnergyStack) -> String:
	return energy_stack.stack.reduce(func(x, y): return x + ENERGY_TO_LETTER[y], "")

func _to_string() -> String:
	return energy_to_string(self)

static func string_to_energy(string: String) -> EnergyStack:
	string = string.to_upper()
	var array : Array[EnergyType] = []
	for c in string:
		if c in LETTER_TO_ENERGY.keys():
			array.append(LETTER_TO_ENERGY[c])
	var energy_stack = EnergyStack.new(array)
	energy_stack.sort()
	return energy_stack

func _init(_stack: Array[EnergyType] = []) -> void:
	stack = _stack.duplicate()
	sort()
