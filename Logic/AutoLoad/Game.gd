class_name GameSingleton extends Node

var game_version_string: String = "1.0 - First Prototype"
var review_questions: Array[String] = []
const _SAVE_DIR_USER_REVIEWS = "user://reviews/"
const GOOGLE_DRIVE_REVIEWS_LINK = "https://drive.google.com/drive/folders/1o0zJrVl51mmWTfiNKrZq-RvV7wg2pnY2?usp=sharing"
var combat_to_review: Combat

const _SAVE_DIR_RES = "res://Prototype/Savefiles/"
const _SAVE_DIR_USER = "user://"
var SAVE_DIR = _SAVE_DIR_USER if OS.has_feature("template") else _SAVE_DIR_RES
const PROTOTYPE_BILLBOARD_DIR = "res://Assets/Sprites/PrototypeBillboard/"

var world: World = null

var settings: Settings = load("res://Prototype/default_game_settings.tres")

# todo: add these to Settings.gd
const DEBUG_SKIP_OVERWORLD = true
const DEBUG_SKIP_POST_COMBAT = true
const DEBUG_DECK_VIEW = false
const DEBUG_DECK_PURGE = false
var DEBUG_INFO: bool:
	get:
		return DebugInfo.ACTIVE
var DEBUG_SPELL_TESTING := false # Not meant to be changed.
# Play the scene SpellTest.tscn to start spell testing
var testing_deck: Array[SpellType]
var testing_energy: EnergyStack

var tree: SceneTree:
	get:
		return get_tree()

var combats: Array[Combat] # For debuging


# --- PAUSE STUFF ---	
@onready var pause_activity: PauseActivity = PauseActivity.new()
signal got_paused
signal got_unpaused
func _input(e) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			unpause()
		else:
			pause()
			
func pause():
	ActivityManager.push(pause_activity)
	get_tree().paused = true
	got_paused.emit()
	
func unpause():
	ActivityManager.pop()
	get_tree().paused = false
	got_unpaused.emit()
# --- PAUSE STUFF OVER ---


class DeckUtils:
	static func create_spell(spell_type: SpellType, combat: Combat) -> Spell:
		return Spell.new(spell_type, combat)
	
	static func load_spell(name: String, combat: Combat) -> Spell:
		return Spell.new(SpellType.load_from_file("res://Content/Spells/%s.tres" % name), combat)
	
	static func load_spell_n_times(name: String, n: int, combat: Combat) -> Array[Spell]:
		var spells: Array[Spell] = []
		for i in range(n):
			spells.append(load_spell(name, combat))
		return spells
	
	static func create_test_deck_serialized() -> Array[SpellState]:
		var spell_states: Array[SpellState] = []
		for i in create_test_deck(null):
			spell_states.append(i.serialize())
		return spell_states
	
	static func create_test_deck(combat: Combat) -> Array[Spell]:
		var spells: Array[Spell] = []
		spells.append_array(load_spell_n_times("MudArmor", 1, combat))
		spells.append_array(load_spell_n_times("AirMissile", 1, combat))
		spells.append_array(load_spell_n_times("Berserker", 1, combat))
		#spells.append_array(load_spell_n_times("TrappingRoots", 1, combat))
		spells.append_array(load_spell_n_times("SummonBush", 1, combat))
		
		spells.append_array(load_spell_n_times("SporeFlight", 1, combat))
		spells.append_array(load_spell_n_times("Cyclone", 1, combat))
		spells.append_array(load_spell_n_times("SelfHeal", 1, combat))
		spells.append_array(load_spell_n_times("GrowingMycel", 1, combat))
		spells.append_array(load_spell_n_times("DeadlyDart", 1, combat))
		
		spells.append_array(load_spell_n_times("RockBlast", 1, combat))
		spells.append_array(load_spell_n_times("SummonWitchTotem", 1, combat))
		spells.append_array(load_spell_n_times("Teleport", 1, combat))
		spells.append_array(load_spell_n_times("Breath", 1, combat))
		spells.append_array(load_spell_n_times("SpellMemory", 1, combat))
		
		spells.append_array(load_spell_n_times("WaterBlast", 1, combat))
		spells.append_array(load_spell_n_times("LightningStrike", 1, combat))
		spells.append_array(load_spell_n_times("PoisonPunch", 1, combat))
		spells.append_array(load_spell_n_times("Lifesteal", 1, combat))
		
		spells.shuffle()
		
		return spells
	
	static func deck_for_spell_testing(combat: Combat) -> Array[Spell]:
		var spells: Array[Spell] = []
		for spell_type in Game.testing_deck:
			spell_type._on_load()
			spells.append(create_spell(spell_type, combat))
		#for spell in spells:
			#spell.id = SpellID.new(Game.add_to_spell_count())
		return spells
