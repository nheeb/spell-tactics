
class_name SpellType extends CastableType

@export_category("Spell Attributes")
## Energy costs of the card
@export var costs: EnergyStack
@export var keywords: Array[Keyword]

func _on_load() -> void:
	super._on_load()

	if costs == null:
		costs = EnergyStack.new([])

	for keyword in keywords:
		keyword.on_load()
