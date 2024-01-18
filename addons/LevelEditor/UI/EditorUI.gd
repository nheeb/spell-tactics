
class_name EditorUI extends Control

var tool_pencil = Pencil.new()
var tool_raise = Raise.new()
var tool_lower = Lower.new()

const ROCK_ENTITY = preload("res://Entities/Environment/Rock.tres")
const WATER_ENTITY = preload("res://Entities/Environment/WaterTile.tres")
const GRASS_TILE_ENTITY = preload("res://Entities/Environment/GrassTile.tres")
const PLAYER_TYPE = preload("res://Entities/PlayerResource.tres")

var placement_active: EntityType = GRASS_TILE_ENTITY
var tool_active = tool_pencil

func _on_pencil_pressed():
	tool_active = tool_pencil	

func _on_raise_pressed():
	tool_active = tool_raise	

func _on_lower_pressed():
	tool_active = tool_lower

func _on_grass_pressed():
	placement_active = GRASS_TILE_ENTITY

func _on_water_pressed():
	placement_active = WATER_ENTITY

func _on_none_pressed():
	placement_active = null
