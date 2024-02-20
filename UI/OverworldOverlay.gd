extends Control

@onready var health_label = $"./HBoxContainer2/HealthLabel"
@onready var coins_label = $"./HBoxContainer2/CoinsLabel"
@onready var deck_size_label = $"./ViewDeck/HBoxContainer/Label"

func _ready():
	_update()
	Adventure.state_changed.connect(_update)

func _update():
	_update_coins()
	_update_health()
	_update_deck_size()

func _update_coins():
	coins_label.text = str(Adventure.coins)

func _update_health():
	health_label.text = str(Adventure.health)

func _update_deck_size():
	deck_size_label.text = str(len(Adventure.deck_states))

func _on_view_deck_pressed():
	ActivityManager.push(BrowseDeckActivity.new())
