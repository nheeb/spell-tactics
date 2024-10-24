extends EntityStatusLogic

## Logic when status enters the game
## This will only be called when the status effect is applied, not when it is loaded
func _setup_logic() -> void:
	TimedEffect.new_end_phase_trigger_from_callable(poison_damage).register(combat)
	data["planned_damage"] = range(data.get("_lifetime", 0)).map(
		func (x): return data.get("damage", 0)
	)
	pass

## How does the status change, when another instance of the same effect get applied
func _extend(other_status: EntityStatus) -> void:
	var planned_damage: Array = data.get("planned_damage", []) as Array
	var new_damage: int = other_status.data.get("damage", 0) as int
	for i in range(other_status.lifetime):
		if i < planned_damage.size():
			planned_damage[i] = planned_damage[i] + new_damage
		else:
			planned_damage.append(new_damage)

func poison_damage() -> void:
	var planned_damage: Array = data.get("planned_damage", []) as Array
	var damage := 0
	if not planned_damage.is_empty():
		damage = planned_damage.pop_front()
	if entity is HPEntity:
		entity.inflict_damage_with_visuals(damage)
		combat.animation.say(entity, "Poison Damage")
