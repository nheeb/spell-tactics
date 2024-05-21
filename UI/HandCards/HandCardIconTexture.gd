extends Node2D

func _ready() -> void:
	pass

const MAIN_ICON_SIZE = 512.0

func set_spell_type(type: SpellType):
	# Hide all
	for c in get_children():
		c.hide()
	# Main icon
	if type.icon:
		$MainIcon.texture = type.icon
		$MainIcon.scale *= (MAIN_ICON_SIZE / float($MainIcon.texture.get_width()))
		$MainIcon.show()
	# Side icons
	var infos := type.get_side_icon_infos()
	var icons_left := 0
	var icons_right := 0
	for info in infos:
		if info.left:
			icons_left += 1
			var node_name := "HandCardSideIconLeft%s" % icons_left
			if has_node(node_name):
				var icon = get_node(node_name) as HandCardSideIcon
				icon.setup(info)
				icon.show()
			else:
				printerr("SideIcon not found")
		else:
			icons_right += 1
			var node_name := "HandCardSideIconRight%s" % icons_right
			if has_node(node_name):
				var icon = get_node(node_name) as HandCardSideIcon
				icon.setup(info)
				icon.show()
			else:
				printerr("SideIcon not found")
