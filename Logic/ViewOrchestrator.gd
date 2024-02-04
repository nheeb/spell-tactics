class_name ViewOrchestrator extends Node

@export var combat_viewport: SubViewportContainer
@export var world: World
@export var overworld_viewport: SubViewportContainer
@export var overworld: Overworld

@onready var screen_combat: CanvasLayer = $"../ScreenCombat"
@onready var screen_overworld: CanvasLayer = $"../ScreenOverworld"
@onready var screen_game_over: CanvasLayer = $"../ScreenGameOver"
@onready var screen_post_battle: CanvasLayer = $"../ScreenPostBattle"

func _ready():
	Game.view_orchestrator = self
	transition_to_overworld()
	
func _reset():
	screen_combat.hide()
	screen_overworld.hide()
	screen_game_over.hide()
	screen_post_battle.hide()

func transition_to_combat(level_path: String):
	world.start_combat(level_path)
	overworld.set_active(false)
	overworld_viewport.hide()
	combat_viewport.show()
	
	_reset()
	screen_combat.show()
	
func transition_to_game_over():
	_reset()
	screen_game_over.show()
	
func transition_to_post_battle():
	_reset()
	screen_post_battle.show()
	
func transition_to_overworld():
	overworld_viewport.show()
	combat_viewport.hide()
	overworld.set_active(true)
	
	_reset()
	screen_overworld.show()
