@tool
extends Control

@export var display_name: String = ""
@export var res: EntityType = null
@export var editor_ui: EditorUI = null
@export var mode: SelectionUI.Mode = SelectionUI.Mode.Terrain

func _ready():
	$Button.text = display_name
	if res:
		var texture := load("res://Assets/Sprites/PrototypeBillboard/" + res.internal_name + ".png")
		if texture:
			$Button/TextureRect.texture = texture
			$Button/TextureRect.visible = true
		else:
			$Button/TextureRect.visible = false

func _on_button_pressed():
	if mode == SelectionUI.Mode.Terrain:
		editor_ui.placement_active = res
	if mode == SelectionUI.Mode.Entities:
		editor_ui.ent_active = res

