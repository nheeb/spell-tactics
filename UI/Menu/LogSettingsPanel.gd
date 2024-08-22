class_name LogSettingsPanel extends PanelContainer

var combat: Combat

func try_setup():
	for activity in ActivityManager.activity_stack:
		if activity is CombatActivity:
			combat = activity.combat
	setup(combat)

func setup(_combat: Combat = null):
	if _combat == null:
		return
	combat = _combat
	combat.log.log_entry_registered.connect(add_log_entry)

const LOG_ENTRY_UI = preload("res://UI/DebugUI/LogEntryUI.tscn")
func setup_log():
	%Title.text = "Combat Log"
	for entry in combat.log.log_entries:
		add_log_entry(entry)

func add_log_entry(entry: LogEntry):
	if current_mode == Mode.LOG:
		var entry_ui = LOG_ENTRY_UI.instantiate()
		%Entries.add_child(entry_ui)
		%Entries.move_child(entry_ui, 0)
		entry_ui.setup(entry)

const SETTINGS_ENTRY_UI = preload("res://UI/DebugUI/GlobalSettingUI.tscn")
const SETTINGS_FOLDER_UI = preload("res://UI/DebugUI/GlobalSettingFolderUI.tscn")
func setup_settings():
	%Title.text = "Global Settings"
	for folder in DebugInfo.global_settings_folders.keys():
		var folder_ui = SETTINGS_FOLDER_UI.instantiate()
		folder_ui.set_folder_name(folder)
		%Entries.add_child(folder_ui)
		for attr in DebugInfo.global_settings_folders[folder].keys():
			var entry = DebugInfo.global_settings_folders[folder][attr]
			var entry_ui = SETTINGS_ENTRY_UI.instantiate()
			entry_ui.setup(entry)
			%Entries.add_child(entry_ui)

enum Mode {HIDDEN = 0, LOG = 1, SETTINGS = 2}
var current_mode = Mode.HIDDEN
func advance():
	if not is_instance_valid(combat):
		try_setup()
		if not is_instance_valid(combat):
			push_error("Log UI has no combat reference")
			return
	clear_entries()
	@warning_ignore("int_as_enum_without_cast")
	current_mode += 1
	if current_mode > Mode.SETTINGS:
		current_mode = Mode.HIDDEN
	match current_mode:
		Mode.HIDDEN:
			hide()
		Mode.LOG:
			show()
			setup_log()
		Mode.SETTINGS:
			setup_settings()

func get_entries() -> Array:
	return %Entries.get_children()

func clear_entries():
	for c in %Entries.get_children():
		c.queue_free()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("show_log"):
		advance()
