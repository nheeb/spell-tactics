class_name GameSingleton extends Node

enum Energy {
	Life,
	Decay,
	Matter,
	Water,
	Flow,
	Any
}

const PROTOTYPE_VISUALS = preload("res://Entities/Visuals/VisualPrototype.tscn")

const SAVE_DIR_RES = "res://Prototype/Savefiles/"
const SAVE_DIR_USER = "user://"

var tree : SceneTree : 
	get:
		return get_tree()


func get_prototype_deck(combat: Combat) -> Array[Spell]:
	var prototype_deck : Array[Spell] = []
	for i in range(20):
		match randi_range(1,2):
			1: prototype_deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/DoNothing.tres"), combat))
			2: prototype_deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/SelfDamage.tres"), combat))
	return prototype_deck
	
