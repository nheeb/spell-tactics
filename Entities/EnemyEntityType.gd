@tool
class_name EnemyEntityType extends HPEntityType

enum Behaviour {
	Fighter,
	Archer,
	Support
}

@export var behaviour: Behaviour
@export var agility: int = 0
@export var strength: int = 1
@export var accuracy: int = 0
@export var resistance: int = 0
@export var actions: Array[String]
@export var movements: Array[String]
@export var passives: Array[String]

## Overriding base entity method to return more specific type
func create_entity(combat: Combat) -> EnemyEntity:
	# instance visual entity, who adds this to the scene tree?
	# I think we should have a method add_entity() in Tile
	var ent: EnemyEntity = EnemyEntity.new()
	
	ent.combat = combat
	
	if self.visual_scene != null:
		# CARE, this might lead to lag, depending on the use we might want to instantiate later
		ent.visual_entity = self.visual_scene.instantiate()
		ent.visual_entity.type = self
		ent.type = self
	else:
		# for debugging
		ent.visual_entity = Game.PROTOTYPE_VISUALS.instantiate()
		ent.visual_entity.type = self
		ent.type = self
		
	ent.hp = max_hp
	ent.agility = agility
	ent.strength = strength
	ent.accuracy = accuracy
	ent.resistance = resistance

	ent.on_create()

	return ent
