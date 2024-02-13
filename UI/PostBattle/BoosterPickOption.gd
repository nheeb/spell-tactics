extends Button

var booster_pickup_option: BoosterPickupOption

@onready var title_label: Label = $"Container/Label"

func _ready():
	title_label.text = booster_pickup_option.booster_pack.name

func _on_pressed():
	if booster_pickup_option.apply():
		ActivityManager.pop()
