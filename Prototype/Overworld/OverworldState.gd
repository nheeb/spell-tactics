class_name OverworldState extends Resource

@export var random_seed: int = 0
@export var map: OverworldMap
@export var stage: int = 0
@export var player_position: Vector2i = Vector2i(0, 0)
@export var adventure_state: AdventureState
@export var combat_state: CombatState = null
