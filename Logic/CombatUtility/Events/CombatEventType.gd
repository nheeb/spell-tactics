class_name CombatEventType extends Resource

@export_category("Event Attributes")

## Unique entity identifier (name of the resource file)
var internal_name: String = ""

## Name that will be shown ingame
@export var pretty_name: String

## Effect text shown on the card
@export_multiline var effect_text: String

## Fluff text shown on the card
@export_multiline var fluff_text: String

enum OrderPrio {First = 5, Middle = 10, Last = 15}
@export var order: OrderPrio = OrderPrio.Middle

## Icon (and variants) that will be shown in the top screen when active.
@export var icons: Array[Texture]

## If true, the event won't be shown in the current event icons.
@export var hidden_icon := false
## If true, the effect text will be shown during the advance / main effect.
@export var show_info_on_advancing := true
## If the value is > 0, the event will finish automatically after X rounds.
@export var max_duration := 0

## The event effect's parameters (e.g. spawn location of an enemy) as property
## names should go here along with their default values.
@export var default_params := {}

## Logic script
var logic: Script

const DEFAULT_ICON = preload("res://Assets/Sprites/Icons/circle.png")
func get_icon(index := 0) -> Texture:
	return Utility.array_safe_get(icons, index, false, DEFAULT_ICON)

func _on_load() -> void:
	if internal_name == "":
		internal_name = resource_path.split("/")[-1].split(".")[0]
		var directory = "/".join(resource_path.split("/").slice(0, -1))
		logic = load(directory + "/" + internal_name + ".gd")

func create_event(combat: Combat, params := {}) -> CombatEvent:
	_on_load()
	var event := CombatEvent.new()
	event.combat = combat
	# TODO Nitai give Event ID
	event.params = default_params.duplicate(true)
	event.params.merge(params, true)
	return event
