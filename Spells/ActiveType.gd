class_name ActiveType extends SpellType

enum Limitation {
	X_PER_ROUND,
	CONSUMABLE,
	ALWAYS,
	
}

@export_category("Active Attributes")

@export var limitation: Limitation
@export var max_uses_per_round: int
