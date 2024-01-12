extends Control

## This Scene and (almost) every child is meant to be replaced after Milestone-1

const CNC = preload("res://UI/ControlNodeCard.tscn")

var cards : Array[ControlNodeCard]

func add_card(spell: Spell):
	var card = CNC.instantiate()
	card.set_spell(spell)
	cards.append(card)
	$CardContainer.add_child(card)

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

func select_card(spell):
	var card = CNC.instantiate()
	card.set_spell(spell)
	$SelectedCardContainer
