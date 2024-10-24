class_name StatusEffect extends Resource

## Abstract Class for Status Effects like Stun / Poison / etc

@export var logic_setup_done := false

var entity: Entity
var combat: Combat

func setup(_entity: Entity) -> void:
	entity = _entity
	combat = entity.combat
	if not logic_setup_done:
		setup_logic()
		logic_setup_done = true
	setup_visually()

## For overwriting: Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func setup_logic() -> void:
	pass

## For overwriting: Visual changes when status effect enters the game
func setup_visually() -> void:
	pass

## Name of the status effect
func get_status_name() -> String:
	return "invalid_status"

func get_icon_name() -> String:
	return "no icon"

## For overwriting: How does the effect change, when the entity would get another instance of the same effect
func extend(other_status: StatusEffect) -> void:
	pass

## For overwriting: Effects on being removed
func on_remove() -> void:
	pass

func self_remove() -> void:
	entity.remove_status_effect(get_status_name())

#func get_enemy_actions() -> Array[EnemyActionArgs]:
	#return []

func get_reference() -> StatusEffectReference:
	return StatusEffectReference.new(entity.get_reference(), get_status_name())
