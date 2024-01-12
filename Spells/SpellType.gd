class_name SpellType extends Resource

@export_category("Attributes")
## Lowercase unique entity identifier
@export var internal_name: String
## Name that will be shown ingame
@export var pretty_name: String
## Energy costs of the card
@export var costs: Array[Game.Energy]
## Effect text shown on the card
@export_multiline var effect_text: String
## Fluff text shown on the card
@export_multiline var fluff_text: String
## Logic script
@export var logic: Script
