extends Node3D


func get_spell() -> Spell:
	var spell =  $Quad/SubViewport/ControlNodeCard.spell
	print(spell)
	return spell

func set_card(card: ControlNodeCard):
	$Quad/SubViewport.add_child(card)
	
