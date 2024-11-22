class_name Overworld extends Node3D

var random_seed: int = 0
var map: OverworldMap
var player_position: Vector2i = Vector2i(0, 0)
var stage: int = 0

@onready var nodes: LevelNodes = $LevelNodes
@onready var player_marker: Node3D = $Player
@onready var camera: Camera3D = $Camera3D
@onready var path: String = Game.SAVE_DIR + "save.tres"
