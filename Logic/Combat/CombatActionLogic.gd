class_name CombatActionLogic extends CombatLogic

## ACTION
func execute():
	pass

func are_targets_valid(targets: Array, requirement: TargetRequirement, actor: Entity) -> bool:
	return true

## SUBACTION
func set_preview_visuals(show: bool) -> void:
	pass
