class_name SpellReference extends Resource

@export var id: SpellID

var spell: Spell

func _init(_spell: Spell = null) -> void:
	if _spell == null:
		return
	spell = _spell
	id = _spell.id
	if id == null:
		printerr("SpellReference was created on an spell with empty id")

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

func resolve(combat: Combat = null) -> Spell:
	if spell != null:
		return spell
	else:
		if combat != null:
			connect_reference(combat)
			return spell
		else:
			printerr("SpellReference was not connected yet. Either connect it first or call resolve(combat)")
			return null

func is_valid(combat: Combat = null) -> bool:
	return resolve(combat) != null
