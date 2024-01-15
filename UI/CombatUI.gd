class_name CombatUI extends Control

## This Scene and (almost) every child is meant to be replaced after Milestone-1

const CNC = preload("res://UI/ControlNodeCard.tscn")

var combat : Combat
var cards : Array[ControlNodeCard]
var selected_spell: Spell

func add_card(spell: Spell):
	var card = CNC.instantiate()
	card.set_spell(spell)
	cards.append(card)
	$CardContainer.add_child(card)
	card.selected.connect(select_card)

func remove_card(spell: Spell):
	var card_to_remove = null
	for c in $CardContainer.get_children():
		if c is ControlNodeCard:
			if c.spell == spell:
				if card_to_remove == null:
					card_to_remove = c
				else:
					printerr("Two ControlNodeCards share the same spell")
	if card_to_remove != null:
		$CardContainer.remove_child(card_to_remove)
		card_to_remove.queue_free()
	else:
		printerr("Failed to remove a card which spells is not in the hand")

func _on_next_pressed():
	combat.process_player_action(PlayerPass.new())

func _on_cast_pressed():
	var clean_payment_text : String = $EnergyPayment.text
	if ":" in clean_payment_text:
		clean_payment_text = clean_payment_text.split(":")[-1]
	var payment := Utility.string_to_energy(clean_payment_text)
	if is_instance_valid(selected_spell):
		combat.process_player_action(PlayerCast.new(selected_spell, payment))

#func _input(event):
	#if event.is_action_pressed("cancel"):
		#deselect_card()


func select_card(spell: Spell):
	deselect_card()
	selected_spell = spell
	var card = CNC.instantiate()
	card.set_spell(spell, false)
	$SelectedCardContainer.add_child(card)
	$EnergyPayment.visible = true
	var payment = Utility.is_energy_cost_payable(combat.player_energy, spell.logic.get_costs())
	if payment is Array:
		$EnergyPayment.text = "Payment: " + Utility.energy_to_string(payment)
	else:
		$EnergyPayment.text = "Not enough energy"

func deselect_card():
	selected_spell = null
	$EnergyPayment.visible = false
	for c in $SelectedCardContainer.get_children():
		c.queue_free()

func set_status(text: String):
	$Status.text = text

func set_current_energy(energy: Array[Game.Energy]):
	$CurrentEnergy.text = Utility.energy_to_string(energy)

func _ready() -> void:
	deselect_card()
