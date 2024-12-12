extends ActiveLogic

## Here should be the effect
func execute() -> void:
	for ent in target_entities:
		if ent.can_interact:
			await combat.action_stack.process_callable(ent.interact)

## Can a target tile be selected
func is_target_valid(target: Variant, requirement: TargetRequirement) -> bool:
	if target is Entity:
		return target.can_interact
	elif target is Tile:
		return target.entities.any(func (ent: Entity): return ent.can_interact)
	return false
