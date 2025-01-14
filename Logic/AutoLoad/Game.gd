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

const LEVEL_PATH_DEFAULT = "res://Content/Levels/fight.tres"
const LEVEL_PATH_SPELLTEST = "res://Content/Levels/SpellTesting/spell_test.tres"

# todo: add these to Settings.gd
#const DEBUG_SKIP_OVERWORLD = true
#const DEBUG_SKIP_POST_COMBAT = true
const DEBUG_DECK_VIEW = false
const DEBUG_DECK_PURGE = false
const DEBUG_SKIP_DECKSELECTION = false

var DEBUG_INFO: bool:
	get:
		return DebugInfo.ACTIVE
## Play the scene SpellTest.tscn to start spell testing
## Do not change the value
var DEBUG_SPELL_TESTING := false
var LEVEL_EDITOR := false

var DEBUG_OVERLAY : bool = false  # toggled in Combat UI
signal energy_overlay_changed(c: bool)
var ENERGY_OVERLAY: bool = false:
	set(e):
		ENERGY_OVERLAY = e
		# TODO Create a PlayerAction for this as well
		energy_overlay_changed.emit(e)
		
enum DeckChoice {EagerElementalist = 1, TotemTinkerer = 2, Tournament = 3}

var deck_choice: DeckChoice
var testing_deck: Array[SpellType]
var testing_energy: EnergyStack

var tree: SceneTree:
	get:
		return get_tree()

var combats: Array[Combat] # For debugging


func _ready() -> void:
	# so the _input callback is active on pause to unpause 
	self.process_mode = Node.PROCESS_MODE_ALWAYS

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
		return spell_type.create(combat)
	
	static func load_spell(name: String, combat: Combat) -> Spell:
		return create_spell(SpellType.load_from_file("res://Content/Spells/%s.tres" % name), combat)
	
	static func load_spell_n_times(name: String, n: int, combat: Combat) -> Array[Spell]:
		var spells: Array[Spell] = []
		for i in range(n):
			spells.append(load_spell(name, combat))
		return spells
	
	
	const DUPLICATE_COUNT = 2
	
	static func create_test_deck(combat: Combat, deck_choice) -> Array[Spell]:
		var spells: Array[Spell] = []
		match deck_choice:
			1:
		
				spells.append_array(load_spell_n_times("MudArmor", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("AirMissile", DUPLICATE_COUNT, combat))
			
				spells.append_array(load_spell_n_times("SporeFlight", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("GrowingMycel", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("DeadlyDart", DUPLICATE_COUNT, combat))
			
				spells.append_array(load_spell_n_times("RockBlast", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("Teleport", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("Breath", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("SpellMemory", DUPLICATE_COUNT, combat))
			
				spells.append_array(load_spell_n_times("WaterBlast", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("LightningStrike", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("Lifesteal", DUPLICATE_COUNT, combat))
		
			2:
				spells.append_array(load_spell_n_times("SummonEarthTotem", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("SummonFireTotem", DUPLICATE_COUNT, combat))
			
				spells.append_array(load_spell_n_times("SummonWitchTotem", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("TotemPort", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("TotemThud", DUPLICATE_COUNT, combat))
			
				spells.append_array(load_spell_n_times("ExplodeTotem", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("TotemicInspiration", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("Breath", DUPLICATE_COUNT, combat))
				spells.append_array(load_spell_n_times("SpellMemory", DUPLICATE_COUNT, combat))
			3:
				spells.append_array(load_spell_n_times("SummonWitchTotem", DUPLICATE_COUNT, combat))
				
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
