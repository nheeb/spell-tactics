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

## Icon (and variants) that will be shown in the top screen when active.
@export var icons: Array[Texture]

## If true, the event won't be shown in the current event icons.
@export var hidden := false

## Logic script
var logic: Script

func get_icon(index := 0) -> Texture:
	# TODO Nitai default texture for CombatEvent Icons?
	return Utility.array_safe_get(icons, index, false, null)
