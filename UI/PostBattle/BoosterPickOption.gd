extends Button

@export var booster_pack: BoosterPack

@onready var title_label: Label = $"Container/Label"

func _ready():
	title_label.text = booster_pack.name

