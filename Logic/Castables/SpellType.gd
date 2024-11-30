class_name SpellType extends CastableType

## Energy costs of the card
@export var costs: EnergyStack

func create_base_object() -> CombatObject:
	var spell := Spell.new()
	spell.type = self
	return spell

func _on_load() -> void:
	super._on_load()

	if costs == null:
		costs = EnergyStack.new([])
