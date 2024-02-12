@tool
class_name SpellType extends Resource

@export_category("Spell Attributes")
## Lowercase unique entity identifier
var internal_name: String = ""
## Name that will be shown ingame
@export var pretty_name: String
## Energy costs of the card
@export var costs: EnergyStack
@export var keywords: Array[Keyword]
## Effect text shown on the card
@export_multiline var effect_text: String
## Fluff text shown on the card
@export_multiline var fluff_text: String

## Logic script
var logic: Script
## Spells are events when they have this flag
var is_event_spell := false
var is_enemy_event_spell := false

enum Target {
	None,
	Enemy, # any tile with an enemy
	Tile,  # any tile
	TileWithoutObstacles, # tile without nav obstacles (layer 1)
	Tag, # TODO
	Condition, # TODO, custom bool func in SpellLogic
}

## Which, if any, targets this spell requires
@export var target := Target.None

## Max tile range of the target, -1 for unlimited range
@export var target_range := -1
@export var target_min_range := -1

## when target is Tag, which Tag to target
@export var target_tag := ""

static func load_from_file(path: String) -> SpellType:
	var res = load(path)
	res._on_load()
	return res

func _on_load() -> void:
	if internal_name == "":
		internal_name = resource_path.split("/")[-1].split(".")[0]
		var directory = "/".join(resource_path.split("/").slice(0, -1))
		is_event_spell = "Event" in directory
		is_enemy_event_spell = "EnemyEvent" in directory
		logic = load(directory + "/" + internal_name + ".gd")

	if costs == null:
		costs = EnergyStack.new([])

	for keyword in keywords:
		keyword.on_load()

func get_effect_text(used_keywords: Array[Keyword] = []) -> String:
	if not used_keywords:
		used_keywords = keywords
	var keyword_text = ""
	for k in used_keywords:
		keyword_text = keyword_text + " [%s] " % k.pretty_name
	return keyword_text + "\n" + effect_text
