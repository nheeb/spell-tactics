@tool
extends Control

func _on_visibility_changed() -> void:
	if visible:
		psychosis()

var plugin: EditorPlugin

func psychosis():
	if plugin:
		var tab_bar = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_children()[0].get_children()[2].get_children()
		tab_bar[4].visible = false
		await get_tree().create_timer(.1).timeout
		(tab_bar[2] as Button).button_down.emit()
		(tab_bar[2] as Button).pressed.emit()
		await get_tree().create_timer(.1).timeout
		(tab_bar[2] as Button).button_up.emit()
		plugin.psychosis()
		plugin.main_screen = false
		visible = false
