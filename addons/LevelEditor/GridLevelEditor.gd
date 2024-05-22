@tool
extends Node
class_name GridLevelEditor

const LEVEL = preload("res://Logic/Tiles/Level.tscn")

@export var level_name: String = "level_01"

var level: Level = null

func _ready():
	if not Engine.is_editor_hint():
		return
	level = _load_level()
	if level != null:
		add_child(level, true)
	else:
		level = LEVEL.instantiate()
		level.name = 'Level'
		add_child(level, true)
		level.clear()
		level.init_basic_grid(grid_size)
		
	print("LEVEL: ", level)

@export var grid_size: int = 6 : set = _set_grid_size, get = _get_grid_size
func _set_grid_size(new_value):
	if grid_size != new_value:
		grid_size = new_value
		if level != null:
			level.clear()
			level.init_basic_grid(grid_size)
		else:
			level = LEVEL.instantiate()
			level.name = 'Level'
			add_child(level, true)
			level.clear()
			level.init_basic_grid(grid_size)

func _get_grid_size():
	return grid_size
	
func _get_level_file():
	var scene_location = get_tree().edited_scene_root.scene_file_path
	var file_name = level_name + '.tres'
	return scene_location.path_join('../').path_join(file_name)

func _load_level() -> Level:
	var level_file = _get_level_file()
	var combat_state: CombatState = ResourceLoader.load(level_file) as CombatState
	var loaded_level_state = combat_state.level_state as LevelState
	return loaded_level_state.deserialize(null)
	
func save_changes():
	var level_file = _get_level_file()
	var state: CombatState = serialize_level_as_combat_state(level)
	var err = ResourceSaver.save(state, level_file)
	if not err == OK:
		printerr("Err when saving level state: ", err)

func serialize_level_as_combat_state(_level: Level) -> CombatState:
	var state := CombatState.new()
	state.level_state = _level.serialize()
	state.current_round = 1
	state.current_phase = Combat.RoundPhase.CombatBegin
	#state.player_energy = []
	#state.hand_size = 5
	#var useless_spell_state = SpellState.new()
	#useless_spell_state.type = SpellType.load_from_file("res://Spells/AllSpells/SelfDamage.tres")
	#state.deck_states.append_array(range(20).map(func(x): return useless_spell_state))
	#state.hand_states.append_array([])
	#state.discard_pile_states.append_array([])
	return state
