@tool
class_name PsychScreen extends Control

func _on_visibility_changed() -> void:
	if visible:
		psychosis()

var plugin: EditorPlugin

func psychosis():
	if plugin:
		var tab_bar = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_children()[0].get_children()[2].get_children()
		var plugin_button: Button
		var script_button: Button
		for c in tab_bar:
			if "Psychosis" in str(c):
				plugin_button = c as Button
			elif "Script" in str(c):
				script_button = c as Button
		if plugin_button: plugin_button.visible = false
		await get_tree().create_timer(.1).timeout
		if script_button:
			script_button.button_down.emit()
			script_button.pressed.emit()
			await get_tree().create_timer(.1).timeout
			script_button.button_up.emit()
		plugin.psychosis()
		plugin.main_screen = false
		visible = false
