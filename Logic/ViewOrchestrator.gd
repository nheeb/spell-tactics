class_name ViewOrchestrator extends Node

@export var combat_viewport: SubViewportContainer
@export var world: World
@export var overworld_viewport: SubViewportContainer
@export var overworld: Overworld

@export var combat_ui : CanvasLayer

func _ready():
	Game.view_orchestrator = self
	transition_to_overworld()

func transition_to_combat(level_path: String):
	world.start_combat(level_path)
	overworld.to_combat()
	overworld_viewport.hide()
	combat_viewport.show()
	combat_ui.show()
	
func transition_to_overworld():
	overworld_viewport.show()
	combat_viewport.hide()
	combat_ui.hide()
