class_name GameSingleton extends Node

enum Energy {  # you guys prefer all caps? -> no
	Life,
	Decay,
	Stone,
	Water,
	Flow,
	Any
}

var combat: Combat
var combat_ui: CombatUI

var tree : SceneTree : 
	get:
		return get_tree()
