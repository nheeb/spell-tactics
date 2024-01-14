class_name SpellType extends Resource

@export_category("Attributes")
## Lowercase unique entity identifier
var internal_name: String = ""
## Name that will be shown ingame
@export var pretty_name: String
## Energy costs of the card
@export var costs: Array[Game.Energy]
## Effect text shown on the card
@export_multiline var effect_text: String
## Fluff text shown on the card
@export_multiline var fluff_text: String
## Logic script
var logic: Script

static func load_from_file(path: String) -> SpellType:
	var res = load(path)
	res._on_load()
	return res

const ALL_SPELLS_FOLDER = "res://Spells/AllSpells/"

func _on_load() -> void:
	if internal_name == "":
		internal_name = resource_path.split("/")[-1].split(".")[0]
		logic = load(ALL_SPELLS_FOLDER + internal_name + ".gd")

