class_name EditorUI extends Control

@onready var world: World = $"%World"
@onready var selection_ui = $%SelectionUi
@export var combat_state: CombatState = ResourceLoader.load("res://Levels/SpellTesting/spell_test.tres") as CombatState


var tool_terrain_placer = TerrainPlace.new()
var tool_raise = Raise.new()
var tool_lower = Lower.new()
var tool_placer = Placer.new()
var tool_erase = Erase.new()

var ENT_PLAYER = preload("res://Entities/PlayerResource.tres")

# TODO save level on close

var placement_active: EntityType = null
var tool_active = null
var ent_active: EntityType = ENT_PLAYER

@onready var blocker_idx: int = MouseInput.mouse_block.register_blocker()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		%World.relative_motion = event.relative
	
func on_changed_render_resolution(res: Vector2i):
	%Viewport3D.size = res


## LevelEditor should load with a combat state
func _ready() -> void:
	world.load_combat_from_state(combat_state, false)
	Game.settings.changed_render_resolution.connect(on_changed_render_resolution)
	Events.tile_clicked.connect(tile_clicked)
	get_window().title = "SpellTactics Level Editor ❤️"


func _on_terrain_place_pressed() -> void:
	tool_active = tool_terrain_placer
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
	
func tile_clicked(tile):
	if tool_active != null:
		tool_active._apply(world.level, tile, self)
		
func mouse_entered_editor_ui():
	MouseInput.mouse_block.block(blocker_idx)
	
func mouse_exited_editor_ui():
	MouseInput.mouse_block.unblock(blocker_idx)
