extends Control

@export var display_name: String = ""
@export var res: EntityType = null
@export var editor_ui: EditorUI = null
@export var mode: SelectionUI.Mode = SelectionUI.Mode.Terrain

func _ready():
	$Button.text = display_name
	if res:
		var possible_texture_names: Array[String] = []
		possible_texture_names.append(res.internal_name)
		possible_texture_names.append(res.internal_name.to_lower())
		possible_texture_names.append(res.internal_name.to_snake_case())
		for tex_name in possible_texture_names:
			var texture_path := "res://Assets/Sprites/PrototypeBillboard/" + tex_name + ".png"
			if ResourceLoader.exists(texture_path):
				var texture = load(texture_path)
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
