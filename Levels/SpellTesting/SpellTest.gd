extends Node3D

const NOTHING = preload("res://Spells/AllSpells/DoNothing.tres")

@export var test_spell_1: SpellType = NOTHING
@export var test_spell_2: SpellType = NOTHING
@export var test_spell_3: SpellType = NOTHING
@export var test_spell_4: SpellType = NOTHING
@export var test_spell_5: SpellType = NOTHING

func _ready() -> void:
	if get_tree().current_scene == self:
		print("Starting Spell Test Mode")
		Game.DEBUG_SPELL_TESTING = true
		get_tree().change_scene_to_file("res://Logic/Main.tscn")
