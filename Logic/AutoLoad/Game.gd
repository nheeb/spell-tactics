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
const DEBUG_INFO = true
var DEBUG_SPELL_TESTING := false # Not meant to be changed.
# Play the scene SpellTest.tscn to start spell testing
var testing_deck: Array[SpellType]
var testing_energy: EnergyStack

var tree: SceneTree:
	get:
		return get_tree()

var combats: Array[Combat] # For debuging

#func get_prototype_events(combat: Combat) -> Array[Spell]:
	#var prototype_events: Array[Spell] = []
	#
	#prototype_events.append(Spell.new(SpellType.load_from_file("res://Spells/AllEvents/LeafDrop.tres"), combat))
	#prototype_events.append(Spell.new(SpellType.load_from_file("res://Spells/AllEvents/StumpShroom.tres"), combat))
	#prototype_events.append(Spell.new(SpellType.load_from_file("res://Spells/AllEnemyEvents/SpawnGoblinFighter.tres"), combat))
	#
	#for spell in prototype_events:
		#spell.id = SpellID.new(add_to_spell_count())
	#return prototype_events

var spell_count: int = 0
## Prototype Function for creating ids for spells. This will later be done by the Overworld
func add_to_spell_count() -> int:
	spell_count += 1
	return spell_count

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

func get_icon_from_name(icon_name) -> Texture:
	if icon_name is Texture:
		return icon_name
	if icon_name == "" or icon_name == null:
		return null
	return load("res://Assets/Sprites/Icons/%s.png" % icon_name)
