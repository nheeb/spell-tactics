class_name CombatUI extends Control

## This Scene and (almost) every child is meant to be replaced after Milestone-1

const CNC = preload("res://UI/HandCard2D.tscn")

var combat : Combat
var cards : Array[HandCard2D]  # is this needed?
var selected_spell: Spell

func add_card(spell: Spell):
	var card = CNC.instantiate()
	card.set_spell(spell)
	cards.append(card)
	%Cards3D.add_card(card)

func remove_card(spell: Spell):
	var card_to_remove = null
	for c in cards:
		if c.spell == spell:
			if card_to_remove == null:
				card_to_remove = c
			else:
				printerr("Two HandCard2Ds share the same spell")
	if card_to_remove != null:
		%Cards3D.remove_card(card_to_remove)
		cards.erase(card_to_remove)
		card_to_remove.queue_free()
	else:
		printerr("Failed to remove a card whose spell is not in the hand")

func _on_next_pressed():
	combat.input.process_action(PlayerPass.new())

func _on_cast_pressed():
	var clean_payment_text : String = $EnergyPayment.text
	if ":" in clean_payment_text:
		clean_payment_text = clean_payment_text.split(":")[-1]
	var payment := EnergyStack.string_to_energy(clean_payment_text)
	if is_instance_valid(selected_spell):
		combat.input.process_action(PlayerCast.new(selected_spell, payment))

#func _input(event):
	#if event.is_action_pressed("cancel"):
		#deselect_card()


func select_card(spell: Spell):
	deselect_card()
	selected_spell = spell
	var selected_card = CNC.instantiate()
	selected_card.set_spell(spell, false)
	$SelectedCardContainer.add_child(selected_card)
	$EnergyPayment.visible = true
	var payment = combat.energy.player_energy.get_possible_payment(spell.logic.get_costs())
	if payment != null:
		$EnergyPayment.text = "Payment: " + payment.to_string()
	else:
		$EnergyPayment.text = "Not enough energy"
		
	combat.input.process_action(SelectSpell.new(selected_spell))

func deselect_card():
	selected_spell = null
	$EnergyPayment.visible = false
	for c in $SelectedCardContainer.get_children():
		c.queue_free()

func set_status(text: String):
	$Status.text = text


const energy_min_size := 32
const ENERGY_ICON = preload("res://UI/EnergyIcon.tscn")
func set_current_energy(energy: EnergyStack):
	for c in $Energy.get_children():
		if c is EnergyIcon:
			c.queue_free()
	for e in energy.stack:
		var icon = ENERGY_ICON.instantiate()
		$Energy.add_child(icon)
		icon.type = e
		icon.min_size = energy_min_size
		
		
func update_payable_cards():
	pass
		
	

func _ready() -> void:
	deselect_card()
