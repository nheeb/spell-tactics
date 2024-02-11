extends Node3D

const LEVEL = preload("res://Logic/Tiles/Level.tscn")

var test = ["ast", "mast", "past"]

func mist():
	pass

func _ready() -> void:
	print(get("mist"))
	#OS.shell_open(ProjectSettings.globalize_path("user://"))
	#OS.shell_open(Game.GOOGLE_DRIVE_REVIEWS_LINK)
	#print("start_test")
	#
	#var level : Level = LEVEL.instantiate()
	#add_child(level)
	#level.init_basic_grid(3)
	#
	#level.save_without_combat("res://test.tres")
	##Combat.serialize_level_as_combat_state(level).save_to_disk("res://test.tres")
	#var loaded_level: Level = Level.load_without_combat("res://test.tres")
	##var loaded_level: Level = Combat.deserialize_level_from_combat_state(
	#                                                 CombatState.load_from_disk("res://test.tres"))
	
	print("success")
