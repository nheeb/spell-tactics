class_name CombatObjectType extends Resource

func create_base_object() -> CombatObject:
	return null

func create(combat: Combat, props := {}) -> CombatObject:
	var obj := create_base_object()
	obj.update_properties(props)
	obj.connect_with_combat(combat)
	if not obj.born:
		combat.action_stack.push_back(obj.on_birth)
	combat.action_stack.push_back(obj.on_load)
	return obj
