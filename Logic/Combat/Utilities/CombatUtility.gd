class_name CombatUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

func get_reference() -> CombatNodeReference:
	return CombatNodeReference.new(combat.get_path_to(self))
