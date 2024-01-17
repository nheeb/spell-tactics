class_name GameSingleton extends Node

enum Energy {
	Life,
	Decay,
	Stone,
	Water,
	Flow,
	Any
}

const SAVE_DIR_RES = "res://Savefiles/"
const SAVE_DIR_USER = "user://"

var tree : SceneTree : 
	get:
		return get_tree()

