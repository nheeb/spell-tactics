class_name TimedEffect extends Resource

@export var phase: Combat.RoundPhase
@export var entity_reference: EntityReference
@export var spell_reference: SpellReference
@export var method: String
@export var params: Array
@export var delay: int = 1

func set_reference(ref) -> TimedEffect:
	if ref is Entity or ref is Spell:
		ref = ref.get_reference()
	if ref is EntityReference:
		entity_reference = ref
	if ref is SpellReference:
		spell_reference = ref
	return self

func set_method(_method: String, _params := []) -> TimedEffect:
	method = _method
	params = _params
	return self

func set_phase(_phase: Combat.RoundPhase) -> TimedEffect:
	phase = _phase
	return self

func set_delay(_delay: int) -> TimedEffect:
	delay = _delay
	return self

func get_reference():
	if entity_reference != null:
		return entity_reference
	elif spell_reference != null:
		return spell_reference
	else:
		printerr("This TimedEffect has no reference")
		return null

func advance(combat: Combat) -> void:
	delay -= 1
	if delay <= 0:
		get_reference().resolve(combat).callv(method, params)
		combat.timed_effects.erase(self)
		free()
