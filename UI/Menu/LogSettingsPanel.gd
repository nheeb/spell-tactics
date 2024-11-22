class_name LogSettingsPanel extends PanelContainer

@onready var zoom_blocker = GameCamera.zoom_block.register_blocker()
@onready var mouse_blocker = MouseInput.mouse_block.register_blocker()

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

const LOG_ENTRY_UI = preload("res://UI/Menu/LogEntryUI.tscn")
func setup_log():
	for entry in combat.log.log_entries:
		add_log_entry(entry)

func add_log_entry(entry: LogEntry):
	if current_mode == Mode.LOG:
		if entry.type != LogEntry.Type.ActionFinished:
			var entry_ui = LOG_ENTRY_UI.instantiate()
			%Entries.add_child(entry_ui)
			await %ScrollContainer.get_v_scroll_bar().changed
			%ScrollContainer.scroll_vertical = 5 * %ScrollContainer.get_v_scroll_bar().max_value
			
			entry_ui.setup(entry)

const SETTINGS_ENTRY_UI = preload("res://UI/Menu/GlobalSettingUI.tscn")
const SETTINGS_FOLDER_UI = preload("res://UI/Menu/GlobalSettingFolderUI.tscn")
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

enum Mode {HIDDEN = 0, LOG = 1}
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
	if current_mode > Mode.LOG:
		current_mode = Mode.HIDDEN
	match current_mode:
		Mode.HIDDEN:
			hide()
		Mode.LOG:
			show()
			setup_log()

func get_entries() -> Array:
	return %Entries.get_children()

func clear_entries():
	for c in %Entries.get_children():
		c.queue_free()

func _on_mouse_entered() -> void:
	zoom_blocker.block()
	mouse_blocker.block()

func _on_mouse_exited() -> void:
	zoom_blocker.unblock()
	mouse_blocker.unblock()
