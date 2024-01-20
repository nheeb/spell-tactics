@tool
extends Control

@export var display_name: String = ""
@export var res: EntityType = null
@export var editor_ui: EditorUI = null
@export var mode: SelectionUI.Mode = SelectionUI.Mode.Terrain

func _ready():
	$Button.text = display_name

func _on_button_pressed():
	if mode == SelectionUI.Mode.Terrain:
		editor_ui.placement_active = res
	if mode == SelectionUI.Mode.Entities:
		editor_ui.ent_active = res

