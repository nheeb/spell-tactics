@tool
class_name SpellType extends Resource

@export_category("Attributes")
## Lowercase unique entity identifier
var internal_name: String = ""
## Name that will be shown ingame
@export var pretty_name: String
## Energy costs of the card
@export var costs: EnergyStack
## Effect text shown on the card
@export_multiline var effect_text: String
## Fluff text shown on the card
@export_multiline var fluff_text: String
## Logic script
var logic: Script
## Spells are events when they have this flag
@export var is_event_spell := false

enum Target {
	None,
	Enemy,
	Tile,
	Tag, # TODO
	Condition, # TODO, custom bool func in SpellLogic
}

## Which, if any, targets this spell requires
@export var target := Target.None

## Max tile range of the target, -1 for unlimited range
@export var target_range := -1

## when target is Tag, which Tag to target
@export var target_tag := ""

static func load_from_file(path: String) -> SpellType:
	var res = load(path)
	res._on_load()
	return res

const ALL_SPELLS_FOLDER = "res://Spells/AllSpells/"
const ALL_EVENTS_FOLDER = "res://Spells/AllEvents/"

func _on_load() -> void:
	if internal_name == "":
		internal_name = resource_path.split("/")[-1].split(".")[0]
		var directory = "/".join(resource_path.split("/").slice(0, -1))
		#if is_event_spell:  # TODO remove is_event property
		logic = load(directory + "/" + internal_name + ".gd")
		#else:
			#logic = load(directory + internal_name + ".gd")
	if costs == null:
		costs = EnergyStack.new([])
