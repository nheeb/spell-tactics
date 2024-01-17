extends Node

const ROCK = preload("res://Entities/Environment/Rock.tres")
# Called when the node enters the scene tree for the first time.


func save():
	var rock_entity: Entity = ROCK.create_entity(Combat.new())
	# TODO test how it works with an entity with state
	
	# open save file
	var file = FileAccess.open("user://save.bin", FileAccess.WRITE)
	
	file.store_var(rock_entity, true)
	
	file.close()
	
	
func load_file():
	var file = FileAccess.open("user://save.bin", FileAccess.READ)
	var obj = file.get_var(true)
	print(obj)
	

const Level = preload("res://Logic/Tiles/Level.tscn")
func save_Level_scene():
	var level = Level.instantiate()
	add_child(level)
	level.owner = self
	$Level.init_basic_grid(3)

	var packed_scene = PackedScene.new()
	var result = packed_scene.pack($Level)
	if result == OK:
		var error = ResourceSaver.save(packed_scene, "user://saved_Level.scn")
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")

func load_Level_scene():
	var loaded_packed_scene = load("user://saved_Level.tscn")
	var level = loaded_packed_scene.instantiate()
	add_child(level)
	level.owner = self

func _ready() -> void:
	save_Level_scene()
	#load_Level_scene()
