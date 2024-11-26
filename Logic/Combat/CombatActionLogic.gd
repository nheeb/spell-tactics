class_name CombatActionLogic extends CombatLogic

######################
## Getter Variables ##
######################

var action: CombatAction:
	get:
		return combat_object as CombatAction

var details: CombatActionDetails:
	get:
		return action.details

var actor: Entity:
	get:
		return details.actor

var target_tiles: Array[Tile]:
	get:
		return details.get_target_tiles()

var target_tile: Tile:
	get:
		return details.get_target_tile()

var target_entities: Array[Entity]:
	get:
		return details.get_target_entities()

var target_entity: Entity:
	get:
		return details.get_target_entity()

var target_enemies: Array[EnemyEntity]:
	get:
		return details.get_target_enemies()

var target_enemy: EnemyEntity:
	get:
		return details.get_target_enemy()

##########################
## Methods to overwrite ##
##########################

## ACTION
func execute():
	pass

func are_targets_valid(targets: Array, requirement: TargetRequirement, _actor: Entity) -> bool:
	return true

## ACTION
func set_preview_visuals(show: bool, tile: Tile = null) -> void:
	pass
