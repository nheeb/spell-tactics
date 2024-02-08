extends Node3D

const NOTHING = preload("res://Spells/AllSpells/DoNothing.tres")

@export var test_spell_1: SpellType = NOTHING
@export var test_spell_2: SpellType = NOTHING
@export var test_spell_3: SpellType = NOTHING
@export var test_spell_4: SpellType = NOTHING
@export var test_spell_5: SpellType = NOTHING

const MAIN = preload("res://Logic/Main.tscn")

func _ready() -> void:
	if get_tree().current_scene == self:
		print("Starting Spell Test Mode")
		Game.DEBUG_SPELL_TESTING = true
		
		var test_deck = range(1,6).map(func(i): return get("test_spell_%s" % i) if get("test_spell_%s" % i) else NOTHING)
		test_deck.append_array(range(10).map(func(i): return NOTHING))
		Game.testing_deck.append_array(test_deck)
		
		await get_tree().process_frame
		
		get_tree().change_scene_to_packed(MAIN)
