class_name PopUpHandler extends Control


func _ready() -> void:
	var rock: EntityType = load("res://Entities/Environment/Rock.tres") as EntityType
	print(rock)
	Events.tile_hovered_long.connect(show_tile_popup)
	Events.tile_unhovered_long.connect(hide_tile_popup)

var current_tile: Tile
var screen_pos: Vector2 # target from unprojecting the camera
var prev_screen_pos: Vector2

func show_tile_popup(tile: Tile):
	var popup = $PopUp
	popup.name = "PopUp"
	current_tile = tile
	screen_pos = get_viewport().get_camera_3d().unproject_position(tile.global_position)
	popup.position = screen_pos
	popup.show()
	popup.show_tile(tile)

func hide_tile_popup(tile: Tile):
	current_tile = null
	$PopUp.hide()
	

func _process(delta: float) -> void:
	if current_tile != null:
		prev_screen_pos = screen_pos
		screen_pos = get_viewport().get_camera_3d().unproject_position(current_tile.global_position)
		$PopUp.position = $PopUp.position.lerp(screen_pos, 0.99)



func _on_button_pressed() -> void:
	var tile = Tile.new()
	tile.r = 1
	tile.q = 2
	
	$PopUp.show_tile(tile)


const COMBAT := preload("res://Logic/Combat.tscn")
const ROCK := preload("res://Entities/Environment/Rock.tres")
func _on_button_2_pressed() -> void:
	var combat = COMBAT.instantiate()
	#add_child(combat)
	
	#combat.create_prototype_level()
	var tile = Tile.new()
	tile.r = 3
	tile.q = 4
	var test = EntityType.new()
	var rock: EntityType = ROCK as EntityType
	var entity_rock: Entity = rock.create_entity(null)
	var entity: Entity = Combat.WATER_ENTITY.create_entity(null)
	tile.entities = [entity]
	$PopUp.show_tile(tile)
