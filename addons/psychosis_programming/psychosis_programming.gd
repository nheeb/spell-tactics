@tool
extends EditorPlugin

const PSYCH_CONTROL = preload("res://addons/psychosis_programming/PsychControl.tscn")
const PSYCH_SCREEN = preload("res://addons/psychosis_programming/PsychScreen.tscn")

var plugin_control

func _enter_tree() -> void:
	add_tool_menu_item("Enable Psychosis", psychosis)
	plugin_control = PSYCH_SCREEN.instantiate()
	EditorInterface.get_editor_main_screen().add_child(plugin_control)
	plugin_control.hide()
	plugin_control.plugin = self

var psychosis_control: Control
func psychosis() -> void:
	psychosis_control = PSYCH_CONTROL.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, psychosis_control)
	remove_tool_menu_item("Enable Psychosis")

func _exit_tree() -> void:
	remove_tool_menu_item("Enable Psychosis")
	if psychosis_control:
		remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, psychosis_control)

var main_screen := true
func _has_main_screen():
	return main_screen

func _make_visible(visible):
	plugin_control.psychosis()
	#plugin_control.visible = visible

func _get_plugin_name():
	return "Enable Psychosis"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")

