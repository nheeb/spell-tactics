extends HBoxContainer

var folder_name : String
var collapsed := false

func set_folder_name(_name):
	folder_name = _name
	%Name.text = folder_name

var panel: LogSettingsPanel

func _ready() -> void:
	panel = Utility.get_parent_of_type(self, LogSettingsPanel)

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		collapse()

func collapse():
	collapsed = not collapsed
	%Name.text = folder_name + (" (...)" if collapsed else "")
	var entries := panel.get_entries()
	entries = entries.slice(entries.find(self) + 1)
	for entry in entries:
		if entry.get("folder_name"):
			break
		entry.visible = not collapsed
