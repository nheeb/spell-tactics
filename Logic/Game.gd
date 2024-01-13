extends Node

enum Energy {  # you guys prefer all caps?
	Life,
	Decay,
	Stone,
	Water,
	Flow,
	Any
}

var combat: Combat
var hand_ui: HandUI

var tree : SceneTree : 
	get:
		return get_tree()
