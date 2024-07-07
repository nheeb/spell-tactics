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

### Returns combination of the other valids. Is being used by PlayerCast to execute the cast
#func is_all_valid(payment: EnergyStack = null) -> bool:
	#return is_unlocked() and is_payment_valid(payment) and is_current_cast_valid()

### Returns a possible payment (if possible)
#func get_possible_payment() -> EnergyStack:
	#return combat.player_energy.get_possible_payment()

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

### Pays for the costs. Activates the cards effect. Also discards the card from hand
#func cast(payment: EnergyStack = null) -> void:
	#pay_for_spell(payment)
	#for keyword in spell.get_keywords():
		#keyword.logic.before_spell(spell)
	#casting_effect()
	#combat.cards.discard(spell)
	#combat.get_phase_node(Combat.RoundPhase.Spell).state = SpellPhase.CastingState.Selecting
	#for keyword in spell.get_keywords():
		#keyword.logic.after_spell(spell)

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

#func is_unlocked() -> bool:
	#var keywords_unlocked = spell.get_keywords().all(func(k): return k.logic.is_unlocked(spell))
	#return _is_unlocked() and keywords_unlocked

### This is for overriding if there are general cast-conditions
#func _is_unlocked() -> bool:
	#return true
#
### This is for overriding if there are conditions for targets
#func is_current_cast_valid() -> bool:
	#return true

### Most important function for overwriting. Here should be the effect
#func casting_effect() -> void:
	#pass
#
#
