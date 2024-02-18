extends Control

var activity: BrowseDeckActivity
@onready var container: Control = $"ScrollContainer/Container"

func set_activity(_activity: BrowseDeckActivity):
	self.activity = _activity

func _ready():
	for spell_state in Adventure.deck_states:
		var hand_card = preload('res://UI/HandCard2D.tscn').instantiate()
		hand_card.set_spell_type(spell_state.type)
		#var container = HBoxContainer.new()
		#container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		#container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		#container.size = Vector2(100, 100)
		container.add_child(hand_card, true)



func _on_back_pressed():
	ActivityManager.pop()
