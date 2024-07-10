class_name CombatEventIcons extends Control

# @onready var combat_ui: CombatUI = get_parent()

const ICON = preload("res://UI/CombatUI/CombatEventIcon.tscn")
func create_icon(event: CombatEvent) -> CombatEventIcon:
	var icon = ICON.instantiate()
	$Container.add_child(icon)
	icon.visible = false
	icon.event = event
	return icon
