class_name CastableUtility extends CombatUtility

## Returns an Active with given String in its pretty or internal name.
## Case is being ignored.
@warning_ignore("shadowed_variable_base_class")
func get_active_from_name(name: String) -> Active:
	var actives := combat.actives.filter(
		func (a: Active):
			return name.to_lower() in a.type.pretty_name.to_lower() \
				or name.to_lower() in a.type.internal_name.to_lower()
	)
	if actives.is_empty():
		push_error("No active found with name %s" % name)
		return null
	return actives.front() as Active
