class_name EnemyEntityType extends HPEntityType

@export var behaviour: EnemyBehaviour
@export var actions: Array[EnemyActionArgs]

@export_group("Traits")
@export var agility: int = 0
@export var strength: int = 1
@export var accuracy: int = 0
@export var resistance: int = 0
@export var movement_range: int = 2

## Overriding base entity method to return more specific type
func create_entity(combat: Combat, call_on_create := true) -> EnemyEntity:
	# instance visual entity, who adds this to the scene tree?
	# I think we should have a method add_entity() in Tile
	var ent: EnemyEntity = EnemyEntity.new()
	
	setup_visuals_and_logic(ent, combat)
	
	ent.hp = max_hp
	ent.agility = agility
	ent.strength = strength
	ent.accuracy = accuracy
	ent.resistance = resistance
	ent.movement_range = movement_range

	entity_on_create(ent, call_on_create)

	return ent
