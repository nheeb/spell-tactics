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
## The effect of the CombatAction.
func execute():
	pass

## Is the action executable right now with the given details.
func is_executable() -> bool:
	return true

## Override this if you want a certain requirement to have a different target pool.
## If you return [], it will be replaced by the default pool. (e.g. all Tiles)
func get_target_pool(requirement: TargetRequirement) -> Array:
	return []

## For special conditions you can decide if a target fits to a certain requirement.
func is_target_valid(target: Variant, requirement: TargetRequirement) -> bool:
	return true

## ACTION
## Override this when you want to preview the CombatAction.
func set_preview_visuals(show: bool, target = null) -> void:
	pass

## You can return the Tile where the actor will end up being after the action.
## This is only really relevant for Enemy Movement / Pre-Actions.
func get_estimated_destination() -> Tile:
	return null
