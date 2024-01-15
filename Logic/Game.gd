class_name GameSingleton extends Node

enum Energy {
	Life,
	Decay,
	Stone,
	Water,
	Flow,
	Any
}

#var combat: Combat
#var combat_ui: CombatUI

var tree : SceneTree : 
	get:
		return get_tree()


# some common EntityTypes
#const player_type: PlayerEntityType = preload("res://Entities/PlayerResource.tres")

