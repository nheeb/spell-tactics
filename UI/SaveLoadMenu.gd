extends Control

const SAVE_ENTRY = preload("res://UI/SavefileMenuEntry.tscn")

var selected_entry: SavefileMenuEntry
var entries : Array[SavefileMenuEntry] = []
var states : Array[OverworldState] = []

var last_screenshot : ImageTexture

func load_all_savefiles() -> void:
	states.clear()
	var dir = DirAccess.open(Game.SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".tres"):
					var loaded_file := SaveFile.load_from_disk(Game.SAVE_DIR + file_name)
					if loaded_file:
						states.append(loaded_file)
			file_name = dir.get_next()
		states.reverse()
	else:
		print("An error occurred when trying to access the path.")

func setup_entries() -> void:
	entries.clear()
	for c in %SaveEntries.get_children():
		c.queue_free()
	for state in states:
		var entry = SAVE_ENTRY.instantiate()
		%SaveEntries.add_child(entry)
		entry.set_overworld_state(state)
		entries.append(entry)
		entry.select.connect(select_entry)

func select_entry(_selected_entry: SavefileMenuEntry) -> void:
	selected_entry = _selected_entry
	for entry in entries:
		entry.set_highlight(entry == selected_entry)
	%ButtonLoad.disabled = false

func setup(take_screenshot := true):
	if take_screenshot:
		last_screenshot = ImageTexture.create_from_image(Game.get_viewport().get_texture().get_image())
	var t = Thread.new()
	t.start(_setup, Thread.PRIORITY_LOW)
	t.wait_to_finish()

func _setup():
	await VisualTime.new_timer(1.0).timeout
	%ButtonLoad.disabled = true
	%ButtonSave.disabled = true
	%SavenameEdit.text = ""
	load_all_savefiles()
	setup_entries()
	show()

func _ready() -> void:
	%ButtonLoad.disabled = true
	%ButtonSave.disabled = true

func _on_savename_edit_text_changed() -> void:
	%ButtonSave.disabled = len(%SavenameEdit.text) < 4

func _on_button_load_pressed() -> void:
	ActivityManager.clear()
	ActivityManager.push(OverworldActivity.new(selected_entry.overworld_state))

func _on_button_save_pressed() -> void:
	var overworld: Overworld = null
	var combat: Combat = null
	
	for activity in ActivityManager.activity_stack:
		if activity is CombatActivity:
			combat = activity.combat
		elif activity is OverworldActivity:
			overworld = activity.overworld
	
	if not overworld:
		printerr("No Overworld found for saving")
		return
	
	var title : String = %SavenameEdit.text
	var state = overworld.serialize(combat.serialize())
	state.generate_meta(title, last_screenshot)
	SaveFile.save_to_disk(state, Game.SAVE_DIR + state.meta.filename + ".tres")
	setup(false)

func _on_button_close_pressed() -> void:
	hide()
