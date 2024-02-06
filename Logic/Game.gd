class_name GameSingleton extends Node

var game_version_string : String = "1.0 - First Prototype"
var review_questions : Array[String] = []
const _SAVE_DIR_USER_REVIEWS = "user://reviews/"
const GOOGLE_DRIVE_REVIEWS_LINK = "https://drive.google.com/drive/folders/1o0zJrVl51mmWTfiNKrZq-RvV7wg2pnY2?usp=sharing"
var combat_to_review: Combat

const PROTOTYPE_VISUALS = preload("res://Entities/Visuals/VisualPrototype.tscn")

const _SAVE_DIR_RES = "res://Prototype/Savefiles/"
const _SAVE_DIR_USER = "user://"
var SAVE_DIR = _SAVE_DIR_USER if OS.has_feature("standalone") else _SAVE_DIR_RES
const PROTOTYPE_BILLBOARD_DIR = "res://Assets/Sprites/PrototypeBillboard/"

var world: World = null

const DEBUG_SKIP_OVERWORLD = false

var tree : SceneTree : 
	get:
		return get_tree()

func get_prototype_deck(combat: Combat) -> Array[Spell]:
	var prototype_deck : Array[Spell] = []
	for i in range(5):
		#prototype_deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/DoNothing.tres"), combat))
		#prototype_deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/SelfDamage.tres"), combat))
		#prototype_deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/MudArmor.tres"), combat))
		prototype_deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/OmniDamage.tres"), combat))
		#prototype_deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/WaterBlast.tres"), combat))
		#prototype_deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/TrappingRoots.tres"), combat))
		#prototype_deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/SpellMemory.tres"), combat))
		#prototype_deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/Cyclone.tres"), combat))
		#prototype_deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/SelfHeal.tres"), combat))
		#prototype_deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/Berserker.tres"), combat))
		#prototype_deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/GrowingMycel.tres"), combat))
	for spell in prototype_deck:
		spell.id = SpellID.new(add_to_spell_count())
	prototype_deck.shuffle()
	return prototype_deck

func get_prototype_events(combat: Combat) -> Array[Spell]:
	var prototype_events : Array[Spell] = []
	
	prototype_events.append(Spell.new(SpellType.load_from_file("res://Spells/AllEvents/LeafDrop.tres"), combat))
	prototype_events.append(Spell.new(SpellType.load_from_file("res://Spells/AllEvents/StumpShroom.tres"), combat))
	
	for spell in prototype_events:
		spell.id = SpellID.new(add_to_spell_count())
	return prototype_events

var spell_count: int = 0
## Prototype Function for creating ids for spells. This will later be done by the Overworld
func add_to_spell_count() -> int:
	spell_count += 1
	return spell_count
