class_name SaveFile

static var path = Game.SAVE_DIR_RES + "save.tres"

static func delete():
	DirAccess.remove_absolute(path)

static func exists() -> bool:
	return FileAccess.file_exists(path)

static func save_to_disk(overworld_state: OverworldState) -> void:
	var err = ResourceSaver.save(overworld_state, path)#, ResourceSaver.FLAG_BUNDLE_RESOURCES)
	if not err == OK:
		printerr("Err when saving level state: ", err)

static func load_from_disk() -> OverworldState:
	var overworld_state = ResourceLoader.load(path) as OverworldState
	return overworld_state
