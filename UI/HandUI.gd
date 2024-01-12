extends Control

## This Scene and (almost) every child is meant to be replaced after Milestone-1

const CNC = preload("res://UI/ControlNodeCard.tscn")

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
	Game.combat.process_player_action(PlayerPass.new())

func _on_cast_pressed():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("cancel"):
		deselect_card()

func select_card(spell):
	deselect_card()
	selected_spell = spell
	var card = CNC.instantiate()
	card.set_spell(spell)
	$SelectedCardContainer.add_child(card)

func deselect_card():
	selected_spell = null
	for c in $SelectedCardContainer.get_children():
		c.queue_free()
