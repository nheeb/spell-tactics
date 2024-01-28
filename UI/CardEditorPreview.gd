#@tool
extends Node3D

@export var create_preview_cards: bool:
	set(v):
		create_preview_cards = v
		if v:
			create()

@export var cards3d: Cards3D

const card2d = preload("res://UI/HandCard2D.tscn")
func create() -> void:
	#for i in range(5):
		#print("blu")
		#print(cards3d)
		#print(cards3d.has_method("add_card"))
		#cards3d.call("add_card", card2d.instantiate())
		#cards3d.add_card(card2d.instantiate())
	print("??")

