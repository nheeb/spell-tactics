class_name EnergyStack extends Resource

enum EnergyType {
	Empty = 0,
	Decay = 1,
	Matter = 2,
	Harmony = 3,
	Flow = 4,
	Spectral = 5,
	Any = 6,
}

static func type_to_str(type: EnergyType) -> String:
	return EnergyType.keys()[type]

@export var stack : Array[EnergyType] = []

## Returns an EnergyStack with possible payment arrangement if possible or null if not
func get_possible_payment(cost_stack: EnergyStack) -> EnergyStack:
	sort()
	cost_stack.sort()
	var bank := stack.duplicate()
	var cost := cost_stack.stack.duplicate()
	## Ever since the sort reversal we need to reverse the duplicates here
	## TODO nitai make payment algorithm order-robust
	bank.reverse()
	cost.reverse()
	if EnergyType.Any in bank:
		push_error("Any Type Energy should not be in a bank Stack")
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
	if cost.size() != possible_payment.size():
		push_error("Something went wrong in the Payment calculation")
	return EnergyStack.new(possible_payment)

func can_pay_costs(costs: EnergyStack) -> bool:
	return get_possible_payment(costs) != null

func shares_type_with(other: EnergyStack) -> bool:
	for e in stack:
		if e != EnergyType.Any:
			if e in other.stack:
				return true
	return false

func sort(reversed := true) -> void:
	stack.sort()
	if reversed:
		stack.reverse()
	
	
func add(e: EnergyStack) -> EnergyStack:
	stack.append_array(e.stack)
	return self

## Applies a payment (reducing the energy by the exact energies in that payment)
func apply_payment(payment: EnergyStack) -> void:
	for e in payment.stack.duplicate():
		if e in stack:
			stack.erase(e)
		else:
			push_error("Non existing energy was payed.")

const ENERGY_TO_LETTER = {
	EnergyType.Any: "X",
	EnergyType.Empty: "E",
	EnergyType.Decay: "D",
	EnergyType.Matter: "M",
	EnergyType.Harmony: "H",
	EnergyType.Flow: "F",
	EnergyType.Spectral: "S",
}

const LETTER_TO_ENERGY = {
	"X": EnergyType.Any,
	"E": EnergyType.Empty,
	"D": EnergyType.Decay,
	"M": EnergyType.Matter,
	"H": EnergyType.Harmony,
	"F": EnergyType.Flow,
	"S": EnergyType.Spectral,
}

static func energy_to_string(energy_stack: EnergyStack) -> String:
	return energy_stack.stack.reduce(func(x, y): return x + ENERGY_TO_LETTER[y], "")

func _to_string() -> String:
	return EnergyStack.energy_to_string(self)

static func string_to_energy(string: String) -> EnergyStack:
	string = string.to_upper()
	var array : Array[EnergyType] = []
	for c in string:
		if c in LETTER_TO_ENERGY.keys():
			array.append(LETTER_TO_ENERGY[c])
	var energy_stack = EnergyStack.new(array)
	energy_stack.sort()
	return energy_stack

static func single_energy_from_type(type: EnergyType) -> EnergyStack:
	var e = EnergyStack.new()
	e.stack.append(type)
	return e

func _init(_stack: Array[EnergyType] = []) -> void:
	stack = _stack.duplicate()
	sort()

func is_empty() -> bool:
	return stack.is_empty()

func size() -> int:
	return stack.size()

func count(type: EnergyType) -> int:
	return stack.count(type)
