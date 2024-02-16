class_name SaveFile

static func delete(path: String):
	DirAccess.remove_absolute(path)

static func exists(path: String) -> bool:
	return FileAccess.file_exists(path)

static func save_to_disk(overworld_state: OverworldState, path: String) -> void:
	var err = ResourceSaver.save(overworld_state, path)
	if not err == OK:
		printerr("Err when saving level state: ", err)

static func load_from_disk(path: String) -> OverworldState:
	var overworld_state = ResourceLoader.load(path) as OverworldState
	return overworld_state

static func load_thread_request(path : String) -> void:
	ResourceLoader.load_threaded_request(path)

static func load_thread_get(path : String) -> OverworldState:
	return ResourceLoader.load_threaded_get(path) as OverworldState

static func load_thread_status(path: String) -> ResourceLoader.ThreadLoadStatus:
	return ResourceLoader.load_threaded_get_status(path)
