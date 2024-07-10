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

@export var icon: Texture
@export var color: Color = Color.WHITE

## Logic script
var logic: Script
