class_name SpellReference extends UniversalReference

@export var id: SpellID

var spell: Spell

func _init(_spell: Spell = null) -> void:
	if _spell == null:
		return
	spell = _spell
	id = _spell.id
	if id == null:
		printerr("SpellReference was created on an spell with empty id")

## Is called by resolve(combat)
func connect_reference(combat: Combat) -> void:
	for s in combat.get_all_spells():
		if s.id.equals(id):
			if spell == s:
				printerr("SpellReference already connected to that object")
			else:
				if spell != null:
					printerr("SpellReference already connected to another object")
			spell = s
	if spell == null:
		printerr("SpellReference did not get connected")

## Is being called by resolve and should never be called from outside.
func _resolve() -> Object:
	return spell

func get_reference_type() -> String:
	return "SpellReference"