@tool
class_name EditorUI extends Control

@export var selection_ui: SelectionUI = null

var tool_pencil = Pencil.new()
var tool_raise = Raise.new()
var tool_lower = Lower.new()
var tool_placer = Placer.new()
var tool_erase = Erase.new()

var ENT_PLAYER = preload("res://Entities/PlayerResource.tres")

const ROCK_ENTITY = preload("res://Entities/Environment/Rock.tres")
const WATER_ENTITY = preload("res://Entities/Environment/Water.tres")
const GRASS_TILE_ENTITY = preload("res://Entities/Environment/GrassTile.tres")
const PLAYER_TYPE = preload("res://Entities/PlayerResource.tres")

var placement_active: EntityType = GRASS_TILE_ENTITY
var tool_active = tool_pencil

var ent_active: EntityType = ENT_PLAYER

func _on_pencil_pressed():
	tool_active = tool_pencil	
	selection_ui.set_mode(SelectionUI.Mode.Terrain)

func _on_raise_pressed():
	tool_active = tool_raise	
	selection_ui.set_mode(SelectionUI.Mode.Terrain)

func _on_lower_pressed():
	tool_active = tool_lower
	selection_ui.set_mode(SelectionUI.Mode.None)

func _on_place_pressed():
	tool_active = tool_placer
	selection_ui.set_mode(SelectionUI.Mode.Entities)

func _on_erase_pressed():
	tool_active = tool_erase
	selection_ui.set_mode(SelectionUI.Mode.None)

