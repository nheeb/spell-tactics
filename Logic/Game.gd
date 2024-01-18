class_name GameSingleton extends Node

enum Energy {
	Life,
	Decay,
	Stone,
	Water,
	Flow,
	Any
}

const PROTOTYPE_VISUALS = preload("res://Entities/Visuals/VisualPrototype.tscn")

const SAVE_DIR_RES = "res://Prototype/Savefiles/"
const SAVE_DIR_USER = "user://"

var tree : SceneTree : 
	get:
		return get_tree()

