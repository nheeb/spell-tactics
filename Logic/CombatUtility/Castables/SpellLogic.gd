class_name SpellLogic extends CastableLogic

var spell: Spell

func _init(_spell: Spell):
	spell = _spell
	combat = spell.combat
	if spell.type.logic != self.get_script():
		printerr("Weird creation of SpellLogic Object")

func get_castable() -> Castable:
	return spell

## Tests if payment is possible
func is_payment_valid(payment: EnergyStack = null) -> bool:
	if payment == null:
		payment = EnergyStack.new()
	return payment.get_possible_payment(get_costs()) != null

## Deducts the current cards cost from the players engergy
func pay_for_spell(payment: EnergyStack) -> void:
	if is_payment_valid(payment):
		combat.energy.pay(payment)
	else:
		printerr("Wrong payment done")

func before_cast():
	super.before_cast()
	for keyword in spell.get_keywords():
		keyword.logic.before_spell(spell)

func after_cast():
	for keyword in spell.get_keywords():
		keyword.logic.after_spell(spell)
	if spell.get_card().has_empty_energy_sockets():
		printerr("Spell has empty energy sockets after cast!?!?!?")
	var payment := spell.get_card().get_loaded_energy()
	pay_for_spell(payment)
	super.after_cast()
	combat.cards.discard(spell)

## The current costs with all the modifiers if there are any
func get_costs() -> EnergyStack:
	var costs := _get_costs()
	for keyword in spell.get_keywords():
		var logic = keyword.logic as KeywordLogic
		costs = logic.get_updated_energy_price(costs, spell)
	return costs

#####################################
## For overriding in each Castable ##
#####################################

func _get_costs() -> EnergyStack:
	return spell.type.costs
