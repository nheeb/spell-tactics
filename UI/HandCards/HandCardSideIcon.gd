class_name HandCardSideIcon extends Node2D

const ICON_SIZE = 512.0

func setup(info: SideIconInfo) -> void:
	$Sprite2D.texture = Game.get_icon_from_name(info.icon_texture_name)
	if $Sprite2D.texture:
		$Sprite2D.scale *= (ICON_SIZE / float($Sprite2D.texture.get_width()))
	$Label.text = info.icon_caption

class SideIconInfo:
	var icon_texture_name: String
	var icon_caption: String
	var left: bool
	func _init(_icon_texture_name: String, _icon_caption: String, _left := true) -> void:
		icon_texture_name = _icon_texture_name
		icon_caption = _icon_caption
		left = _left
