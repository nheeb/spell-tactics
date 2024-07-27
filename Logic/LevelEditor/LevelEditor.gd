extends Node3D

@onready var world: World = $World
@export var combat_state: CombatState = ResourceLoader.load("res://Levels/SpellTesting/spell_test.tres") as CombatState


#func _get_level_file():
	#var scene_location = get_tree().edited_scene_root.scene_file_path
	#var file_name = level_name + '.tres'
	#return scene_location.path_join('../').path_join(file_name)

func _load_level() -> Level:
	#var level_file = _get_level_file()
	#var combat_state: CombatState = ResourceLoader.load(level_file) as CombatState
	var loaded_level_state = combat_state.level_state as LevelState
	return loaded_level_state.deserialize(null)

## LevelEditor should load with a combat state
func _ready() -> void:
	#var level: Level = _load_level()
	world.load_combat_from_state(combat_state, false)
	#add_child(level, true)
