class_name Discussion extends RefCounted

var value: Variant = null
var base: Variant = null
@warning_ignore("shadowed_global_identifier")
var log := "" # Just for debugging
var data := {}

func _init(_base = null) -> void:
	base = _base
	value = _base
