extends Node3D

const ROCK_ENTITY := preload("res://Entities/Environment/Rock.tres")
const WATER_ENTITY := preload("res://Entities/Environment/Water.tres")
const PLAYER_TYPE := preload("res://Entities/PlayerResource.tres")

const LEVEL := preload("res://Logic/Tiles/Level.tscn")
const COMBAT := preload("res://Logic/Combat.tscn")
const COMBAT_UI := preload("res://UI/CombatUI.tscn")

const LOAD_PROTOTYPE_COMBAT = true

var level : Level
var combat : Combat
var combat_ui : CombatUI

func _ready() -> void:
	level = LEVEL.instantiate()
	level.name = "Level"
	add_child(level)
	level.init_basic_grid(3)
	# let's add some prototyping entities to the level
	level.create_entity(3, 3, ROCK_ENTITY)
	level.create_entity(3, 4, WATER_ENTITY)
	level.player = level.create_entity(0, 6, PLAYER_TYPE)

	if LOAD_PROTOTYPE_COMBAT:
		combat = COMBAT.instantiate()
		add_child(combat)
		combat.create_as_prototype(level)
		combat_ui = COMBAT_UI.instantiate()
		$FeaturesUI.add_child(combat_ui)
		combat.connect_with_ui(combat_ui)
		
		combat.advance_and_process_until_next_player_action_needed()
		combat.animation_utility.play_animation_queue()

	

var flip := false
func _on_movement_range_button_pressed() -> void:
	if not flip:
		var movement_tiles = level.get_all_tiles_in_distance(3, 3, 2)
		level._highlight_tile_set(movement_tiles, Highlight.Type.Movement)
		flip = true
	else:
		var movement_tiles = level.get_all_tiles_in_distance(3, 3, 2)
		level._unhighlight_tile_set(movement_tiles, Highlight.Type.Movement)
		flip = false


var flip2 := false
var ent_type := preload("res://Entities/Environment/Rock.tres")
func _on_entity_find_button_pressed() -> void:
	if not flip2:
		level.highlight_entity_type(ent_type)
		flip2 = true
	else:
		level.unhighlight_entity_type(ent_type)
		flip2 = false

func _on_nav_button_pressed() -> void:
	var search = level.search(Vector2i(0, 6), Vector2i(6, 0))
	search.execute()
	if search.path_found:
		for location in search.path:
			level.tiles[location.x][location.y].set_highlight(Highlight.Type.Movement, true)
	print(search.path)


func _on_move_rock_button_pressed() -> void:
	level.move_entity(level.find_entity(ent_type), level.tiles[5][4])


func _on_damage_player_pressed() -> void:
	level.player.hp -= 1


func _on_save_level_pressed() -> void:
	#level.save_to_disk("user://level.tres")
	combat.save_to_disk("user://combat.tres")


func _on_load_level_pressed() -> void:
	#var loaded_level = Level.load_from_disk("user://level.tres")
	#loaded_level.name = "Level"
	#level.free()
	#add_child(loaded_level)
	for node in [level, combat, combat_ui]:
		node.free()
	combat = Combat.load_from_disk("user://combat.tres")
	add_child(combat)
	level = combat.level
	level.name = "Level"
	add_child(level)
	combat_ui = COMBAT_UI.instantiate()
	$FeaturesUI.add_child(combat_ui)
	combat.connect_with_ui(combat_ui)

var tile_toggle := false
func _on_toggle_tile_labels_pressed() -> void:
	tile_toggle = not tile_toggle
	
	if tile_toggle:
		# 
		pass
