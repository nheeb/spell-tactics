class_name BerserkerEffect extends StatusEffect

## Make persistant vars export so they get serialized automatically since StatusEffect is a Resource

@export var length := 2

## Name of the status effect
func get_status_name() -> String:
	return "berserker"

func get_icon_name() -> String:
	return "axe"

func _init(_length := 2) -> void:
	length = _length

## For overwriting: Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func setup_logic() -> void:
	var melee_attacks = combat.actives.filter(func(x): return "Melee" in x.type.pretty_name)
	for melee in melee_attacks:
		melee = melee as SimpleMelee
		if melee == null:
			push_error("Expected SimpleMelee")
			return
		melee.modifiers.append(func(dmg, target): dmg+1)
	TimedEffect.new_end_phase_trigger_from_callable(func(): pass).set_trigger_count(length) \
			.replace_last_callable(self_remove).register(combat)

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
	for melee in melee_attacks:
		melee.add_to_max_uses(-1)
	combat.animation.remove_staying_effect(entity.visual_entity, "berserker_icons")

