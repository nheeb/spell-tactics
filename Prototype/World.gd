class_name World extends Node3D

const COMBAT = preload("res://Logic/Combat.tscn")
const COMBAT_UI = preload("res://UI/CombatUI.tscn")

var level : Level
@onready var combat : Combat
@onready var combat_ui : CombatUI
@onready var debug_ui: Control

func _ready() -> void:
	combat = COMBAT.instantiate()
	add_child(combat)
	
	var combat_state: CombatState = load('res://Levels/Area1/rivers.tres')
	print(combat_state)
	level = combat_state.level_state.deserialize(combat)
	add_child(level)
	combat.level = level
	combat.create_prototype_level()
	#add_child(combat.level)
	#level = combat.level
	
	# construct references to ui_root which lives outside this 3d viewport
	# ui_root/combat_ui and ui_root/debug_ui
	var ui_root = get_tree().get_first_node_in_group("ui_root")
	debug_ui = ui_root.get_node("DebugUI")
	combat_ui = COMBAT_UI.instantiate()
	ui_root.add_child(combat_ui)
	combat.connect_with_ui(combat_ui)
	
	combat.advance_and_process_until_next_player_action_needed()
	combat.animation.play_animation_queue()
	
	


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
var ent_type = preload("res://Entities/Environment/Rock.tres")
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
	combat.movement.move_entity(level.find_entity_type(ent_type), level.tiles[5][4])
	combat.animation.play_animation_queue()

func _on_damage_player_pressed() -> void:
	level.player.hp -= 1


func _on_save_game_pressed(id: String) -> void:
	#level.save_to_disk("user://level.tres")
	combat.save_to_disk(Game.SAVE_DIR_RES + "combat-%s.tres" % id)


func _on_load_game_pressed(id: String) -> void:
	#var loaded_level = Level.load_from_disk("user://level.tres")
	#loaded_level.name = "Level"
	#level.free()
	#add_child(loaded_level)
	for node in [level, combat, combat_ui]:
		if is_instance_valid(node):
			node.free()
	combat = Combat.load_from_disk(Game.SAVE_DIR_RES + "combat-%s.tres" % id)
	add_child(combat)
	level = combat.level
	level.name = "Level"
	add_child(level)
	combat_ui = COMBAT_UI.instantiate()
	var ui_root = get_tree().get_first_node_in_group("ui_root")
	ui_root.add_child(combat_ui)
	combat.connect_with_ui(combat_ui)

var tile_toggle := false
func _on_toggle_tile_labels_pressed() -> void:
	tile_toggle = not tile_toggle
	
	if tile_toggle:
		# 
		pass


func _on_show_debug_pressed() -> void:
	debug_ui.get_node("%List").visible = not debug_ui.get_node("%List").visible
	if debug_ui.get_node("%List").visible:
		debug_ui.get_node("%ShowDebug").text = "Hide Debug"
	else:
		debug_ui.get_node("%ShowDebug").text = "Show Debug"


func _on_line_button_pressed() -> void:
	# TODO implement drawing line
	pass # Replace with function body.
