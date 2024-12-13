class_name CastableType extends CombatActionType

## Energy costs of the card
@export var costs: EnergyStack

## Effect text shown on the card
@export_multiline var effect_text: String

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

@export_group("Side / Topic Icons")
@export var topic: SpellTopic = SpellTopic.None
@export var topic_secondary: SpellTopic = SpellTopic.None
@export var topic_icons: Array[SpellTopic] = []
@export var topic_caption := ""

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
	# TODO reimplement
	#var target_text := ""
	#var target_range_start = target_min_range
	#var target_range_end = target_range
	#if target_range_start == -1:
		#if target_range_end == -1:
			#target_text = ""
		#else:
			#target_text = "<%s" % target_range_end
	#else:
		#if target_range_end == -1:
			#target_text = ">%s" % target_range_start
		#else:
			#target_text = "%s-%s" % [target_range_start, target_range_end]
	#icon_infos.append(HandCardSideIcon.SideIconInfo.new(
		#TargetIconName[target], target_text, false
	#))
	return icon_infos

func _on_load() -> void:
	super._on_load()
	if costs == null:
		costs = EnergyStack.new([])

func get_main_energy() -> EnergyStack.EnergyType:
	if costs.size() > 0:
		return costs.stack.front()
	return EnergyStack.EnergyType.Any
