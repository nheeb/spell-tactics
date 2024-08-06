class_name BerserkerEffect extends StatusEffect

## Make persistant vars export so they get serialized automatically since StatusEffect is a Resource

@export var length := 2

@export var callable_reference: CallableReference 

## Name of the status effect
func get_status_name() -> String:
	return "berserker"

func get_icon_name() -> String:
	return "axe"

func _init(_length := 2) -> void:
	length = _length
	
	
func berserker_effect(dmg: int, _target: EnemyEntity):
	return dmg + 1

## For overwriting: Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func setup_logic() -> void:
	var melee_attacks = combat.actives.filter(func(x): return "Melee" in x.type.pretty_name)
	for melee in melee_attacks:
		if melee == null:
			push_error("Found no SimpleMelee active.")
			return
		callable_reference = CallableReference.from_callable(berserker_effect)
		melee.logic.modifiers.append(callable_reference)
	
	# effect for removing effect after length rounds
	TimedEffect.new_end_phase_trigger_from_callable(self_remove).set_delay(1) \
			.register(combat)

## For overwriting: Visual changes when status effect enters the game
func setup_visually() -> void:
	combat.animation.add_staying_effect(VFX.ICON_VISUALS, entity.visual_entity, "berserker_icons", \
					{"icon_name": get_icon_name(), "color": Color.ORANGE})

## For overwriting: How does the effect change, when the entity would get another instance of the same effect
func extend(other_status: StatusEffect) -> void:
	for timed_effect in combat.t_effects.get_effects(self):
		timed_effect.triggers_left += other_status.length

## For overwriting: Effects on being removed
func on_remove() -> void:
	var melee_attacks = combat.actives.filter(func(x): return "Melee" in x.type.pretty_name)
	assert(len(melee_attacks) == 1)
	var melee = melee_attacks[0]
	var i = 0
	var found_idx: int = -1
	for modifier in melee.logic.modifiers:
		var cb_reference: CallableReference = modifier as CallableReference
		var obj = cb_reference.origin_reference.resolve(combat)
		print("resolve obj: ", obj)
		if obj == self:
			found_idx = i
		i += 1
	assert(found_idx != -1)
	melee.logic.modifiers.remove_at(found_idx)
	combat.animation.remove_staying_effect(entity.visual_entity, "berserker_icons")

