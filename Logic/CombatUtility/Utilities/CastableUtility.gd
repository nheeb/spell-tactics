class_name CastableUtility extends CombatUtility

# TODO save castable states and objects in here to make Combat.gd smaller

## Returns an Active with given String in its pretty or internal name.
## Case is being ignored.
func get_active_from_name(name: String) -> Active:
	var actives := combat.actives.filter(
		func (a: Active):
			return name.to_lower() in a.type.pretty_name.to_lower()
	)
	if actives.is_empty():
		push_error("No active found with name %s" % name)
	return actives.front() as Active
