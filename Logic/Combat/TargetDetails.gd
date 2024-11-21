class_name TargetDetails extends RefCounted

enum Type {
	Tile,
	Spell,
	EnergyStack
}

enum Limitation {
	NoBlocker,
	Enemy,
	EntityWithTag,
}

enum RangeSize {
	ADJACENT = 1,
	SHORT = 2,
	MEDIUM = 4,
	LONG = 6,
	UNLIMITED = 99
}

var combat_action: CombatObject
var requirements: Array[TargetRequirement]
## {TargetRequirement -> Value}
var details: Dictionary
