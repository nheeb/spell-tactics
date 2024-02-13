extends Button

var coin_pickup_option: CoinPickupOption

@onready var label: Label = $"./Container/Label"

func _ready():
	label.text = "%s coins" % str(coin_pickup_option.coin_amount)

func _on_pressed():
	if coin_pickup_option.apply():
		ActivityManager.pop()
