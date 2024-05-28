@tool
class_name CastableType extends Resource

@export_category("Spell Attributes")
## Lowercase unique entity identifier
var internal_name: String = ""
## Name that will be shown ingame
@export var pretty_name: String
## Effect text shown on the card
@export_multiline var effect_text: String
## Fluff text shown on the card
@export_multiline var fluff_text: String

@export var icon: Texture
@export var color: Color = Color.WHITE

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
	Cone
}

const TargetIconName = {
	Target.None: "",
	Target.Enemy: "goblin",
	Target.Tile: "hexagon", 
	Target.TileWithoutObstacles: "hexagon",
	Target.Tag: "question",
	Target.Condition: "question",
	Target.Cone: "cone"
}

## Which, if any, targets this spell requires
@export var target := Target.None

## Max tile range of the target, -1 for unlimited range
@export var target_range := -1
@export var target_min_range := -1

## when target is Tag, which Tag to target
@export var target_tag := ""
@export var target_count_min := 1
@export var target_count_max := 1

@export var target_possible_highlight: Highlight.Type = Highlight.Type.PossibleTarget
@export var target_selected_highlight: Highlight.Type = Highlight.Type.SelectedTarget

enum SpellTopic {
	None,
	Damage,
	Defense,
	Movement,
	Energy,
	Trap,
	Totem,
	Poison,
	Death,
	Grow,
	AreaDamage,
	Heal,
	SpellDraw,
	Buff,
	Other,
	Wet,
	Snare,
	Knockback
}

const TopicIconName = {
	SpellTopic.None: "",
	SpellTopic.Damage: "axe",
	SpellTopic.Defense: "shield",
	SpellTopic.Movement: "run",
	SpellTopic.Energy: "question",
	SpellTopic.Trap: "trap",
	SpellTopic.Totem: "totem",
	SpellTopic.Poison: "poison",
	SpellTopic.Death: "skull",
	SpellTopic.Grow: "sprout",
	SpellTopic.AreaDamage: "area-damage",
	SpellTopic.Heal: "hearts",
	SpellTopic.SpellDraw: "card-pickup",
	SpellTopic.Buff: "upgrade",
	SpellTopic.Other: "question",
	SpellTopic.Wet: "drop",
	SpellTopic.Snare: "thorns",
	SpellTopic.Knockback: "plain-arrow-right"
}

@export var topic: SpellTopic = SpellTopic.None
@export var topic_secondary: SpellTopic = SpellTopic.None
@export var topic_icons: Array[SpellTopic] = []
@export var topic_caption := ""

static func load_from_file(path: String) -> CastableType:
	var res = load(path)
	if res == null:
		printerr("Castable could not be loaded. Path is %s" % path)
	res._on_load()
	return res

func _on_load() -> void:
	if internal_name == "":
		internal_name = resource_path.split("/")[-1].split(".")[0]
		var directory = "/".join(resource_path.split("/").slice(0, -1))
		is_event_spell = "Event" in directory
		is_enemy_event_spell = "EnemyEvent" in directory
		logic = load(directory + "/" + internal_name + ".gd")

func get_effect_text(used_keywords: Array[Keyword] = []) -> String:
	var keyword_text = ""
	for k in used_keywords:
		keyword_text = keyword_text + " [%s] " % k.pretty_name
	return keyword_text + "\n" + effect_text

func get_side_icon_infos() -> Array[HandCardSideIcon.SideIconInfo]:
	# Left Topic Icons
	var icons = topic_icons.duplicate()
	for ic in [topic_secondary, topic]:
		if ic != SpellTopic.None:
			icons.push_front(ic)
	var captions = topic_caption.split(",")
	var icon_infos : Array[HandCardSideIcon.SideIconInfo] = []
	for i in range(icons.size()):
		var ic = icons[i]
		icon_infos.append(HandCardSideIcon.SideIconInfo.new(
			TopicIconName[ic], Utility.array_safe_get(captions, i, false, "")
		))
	# Right Target Icon
	var target_text := ""
	var target_range_start = target_min_range
	var target_range_end = target_range
	if target_range_start == -1:
		if target_range_end == -1:
			target_text = ""
		else:
			target_text = "<%s" % target_range_end
	else:
		if target_range_end == -1:
			target_text = ">%s" % target_range_start
		else:
			target_text = "%s-%s" % [target_range_start, target_range_end]
	icon_infos.append(HandCardSideIcon.SideIconInfo.new(
		TargetIconName[target], target_text, false
	))
	
	return icon_infos
