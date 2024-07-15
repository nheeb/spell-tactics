class_name CastableReference extends UniversalReference

@export var spell_ref: SpellReference
@export var active_ref: ActiveReference
var castable: Castable

func _init(_castable: Castable = null) -> void:
	if _castable == null:
		return
	castable = _castable
	if castable is Active:
		active_ref = castable.get_reference()
	elif castable is Spell:
		spell_ref = castable.get_reference()
	else:
		printerr("CastableRef: Something went wrong.")

## Is called by resolve(combat)
func connect_reference(combat: Combat) -> void:
	if spell_ref:
		castable = spell_ref.resolve(combat)
	elif active_ref:
		castable = active_ref.resolve(combat)
	else:
		printerr("Empty Castable Reference")

## Is being called by resolve and should never be called from outside.
func _resolve() -> Object:
	return castable

func get_reference_type() -> String:
	return "CastableReference"
