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
	combat.input.process_action(PlayerPass.new())

func _on_cast_pressed():
	var clean_payment_text : String = $EnergyPayment.text
	if ":" in clean_payment_text:
		clean_payment_text = clean_payment_text.split(":")[-1]
	var payment := Utility.string_to_energy(clean_payment_text)
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
	var payment = Utility.is_energy_cost_payable(combat.energy.player_energy, spell.logic.get_costs())
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


const energy_min_size := 32
const ENERGY_ICON = preload("res://UI/EnergyIcon.tscn")
func set_current_energy(energy: Array[Game.Energy]):
	for c in $Energy.get_children():
		if c is EnergyIcon:
			c.queue_free()
	for e in energy:
		var icon = ENERGY_ICON.instantiate()
		$Energy.add_child(icon)
		icon.type = e
		icon.min_size = energy_min_size
		
	

func _ready() -> void:
	deselect_card()
