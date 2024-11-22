class_name TargetRequirement extends Resource

enum Type {
	None,
	Tile,
	Entity,
	Spell,
	EnergyStack
}

enum Limitation {
	NoBlocker = 1,
	Enemy = 2,
	EntityWithTag = 4,
}

enum RangeSize {
	UNLIMITED = 0,
	ADJACENT = 1,
	SHORT = 2,
	MEDIUM = 4,
	LONG = 6,
	EXTREME = 8,
}

@export var type: Type
@export_flags(
	"No Blocker / Obstacle:1",
	"Enemy:2",
	"Entity with special Tag:4",
) var limitation: int
@export var range_size: RangeSize
@export var count_min := 1
@export var count_max := 1

@export_group("Extras")
@export var custom_tag := ""

@export_group("Highlight")
@export var possible_highlight: Highlight.Type = Highlight.Type.PossibleTarget
@export var selected_highlight: Highlight.Type = Highlight.Type.SelectedTarget
