class_name SaveFile

static func delete(path: String):
	DirAccess.remove_absolute(path)

static func exists(path: String) -> bool:
	return FileAccess.file_exists(path)

static func save_to_disk(combat_state: CombatState, path: String) -> void:
	var thread := Thread.new()
	thread.start(
		_save_to_disk.bind(combat_state, path)
	)
	while thread.is_alive():
		await VisualTime.visual_process
	thread.wait_to_finish()

static func _save_to_disk(combat_state: CombatState, path: String) -> void:
	return
	# FIXME Reimplement this
	# ERROR SaveFile.gd:19 @ _save_to_disk(): Resource was not pre cached for the resource section, bug?
	#var err = ResourceSaver.save(combat_state, path)
	#if not err == OK:
		#push_error("Err when saving level state: ", err)

static func load_from_disk(path: String) -> CombatState:
	var overworld_state = ResourceLoader.load(path) as CombatState
	return overworld_state

static func load_thread_request(path : String) -> void:
	ResourceLoader.load_threaded_request(path)

static func load_thread_get(path : String) -> CombatState:
	return ResourceLoader.load_threaded_get(path) as CombatState

static func load_thread_status(path: String) -> ResourceLoader.ThreadLoadStatus:
	return ResourceLoader.load_threaded_get_status(path)
