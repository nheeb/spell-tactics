extends Node3D

const ROCK_ENTITY := preload("res://Entities/Environment/Rock.tres")
const WATER_ENTITY := preload("res://Entities/Environment/Water.tres")
const PLAYER_TYPE := preload("res://Entities/PlayerResource.tres")

const COMBAT = preload("res://Logic/Combat.tscn")
const COMBAT_UI = preload("res://UI/CombatUI.tscn")

const LOAD_PROTOTYPE_COMBAT = true

func _ready() -> void:
	$Level.init_basic_grid(3)
	# let's add some prototyping entities to the level
	$Level.create_entity(3, 3, ROCK_ENTITY)
	$Level.create_entity(3, 4, WATER_ENTITY)
	$Level.player = $Level.create_entity(0, 6, PLAYER_TYPE)


	if LOAD_PROTOTYPE_COMBAT:
		var new_combat = COMBAT.instantiate()
		add_child(new_combat)
		new_combat.create_as_prototype($Level)
		var new_ui = COMBAT_UI.instantiate()
		$FeaturesUI.add_child(new_ui)
		new_combat.connect_with_ui(new_ui)
		#Game.combat = new_combat
		#Game.combat_ui = new_ui
		
		new_combat.advance_and_process_until_next_player_action_needed()
		new_combat.animation_utility.play_animation_queue()

	

var flip := false
func _on_movement_range_button_pressed() -> void:
	if not flip:
		var movement_tiles = $Level.get_all_tiles_in_distance(3, 3, 2)
		$Level._highlight_tile_set(movement_tiles, Highlight.Type.Movement)
		flip = true
	else:
		var movement_tiles = $Level.get_all_tiles_in_distance(3, 3, 2)
		$Level._unhighlight_tile_set(movement_tiles, Highlight.Type.Movement)
		flip = false


var flip2 := false
var ent_type := preload("res://Entities/Environment/Rock.tres")
func _on_entity_find_button_pressed() -> void:
	if not flip2:
		$Level.highlight_entity_type(ent_type)
		flip2 = true
	else:
		$Level.unhighlight_entity_type(ent_type)
		flip2 = false

func _on_nav_button_pressed() -> void:
	var search = $Level.search(Vector2i(0, 6), Vector2i(6, 0))
	search.execute()
	if search.path_found:
		for location in search.path:
			$Level.tiles[location.x][location.y].set_highlight(Highlight.Type.Movement, true)
	print(search.path)


func _on_move_rock_button_pressed() -> void:
	$Level.move_entity($Level.find_entity(ent_type), $Level.tiles[5][4])


func _on_damage_player_pressed() -> void:
	$Level.player.hp -= 1


func _on_save_level_pressed() -> void:
	$Level.save_to_disk("user://level.tres")


func _on_load_level_pressed() -> void:
	var loaded_level = Level.load_from_disk("user://level.tres")
	loaded_level.name = "Level"
	$Level.free()
	add_child(loaded_level)

var tile_toggle := false
func _on_toggle_tile_labels_pressed() -> void:
	tile_toggle = not tile_toggle
	
	if tile_toggle:
		# 
		pass
