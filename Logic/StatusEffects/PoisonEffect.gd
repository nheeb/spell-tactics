class_name PoisonEffect extends StatusEffect

## Make persistant vars export so they get serialized automatically since StatusEffect is a Resource

@export var length := 3

## make_timed_effect_self_call(method: String, params := []) -> TimedEffect:
## make_timed_effect_entity_call(method: String, params := []) -> TimedEffect:
## You can use those wrapper functions to create timed effects
## (they get added into the combat automatically and are set on EndPhase by default)
## self_remove() is a shortcut for entity.remove_status_effect(get_status_name())

## Name of the status effect
func get_status_name() -> String:
	return "poison"

func _init(_length := 3) -> void:
	length = _length

## For overwriting: Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func setup_logic() -> void:
	TimedEffect.new_end_phase_trigger_from_callable(poison_damage).set_trigger_count(length)\
	.extra_last_callable(self_remove).register(combat)

## For overwriting: Visual changes when status effect enters the game
func setup_visually() -> void:
	combat.animation.add_staying_effect(VFX.ICON_VISUALS, entity.visual_entity, "poison_icons", {"icon_name": "poison", "color": Color.DARK_VIOLET})

## For overwriting: How does the effect change, when the entity would get another instance of the same effect
func extend(other_status: StatusEffect) -> void:
	for te in combat.t_effects.get_effects(self):
		te.triggers_left += other_status.get("length")

## For overwriting: Effects on being removed
func on_remove() -> void:
	combat.animation.remove_staying_effect(entity.visual_entity, "poison_icons")

func poison_damage() -> void:
	entity = entity as EnemyEntity
	entity.inflict_damage(1)
	combat.animation.update_hp(entity)
	combat.animation.say(entity.visual_entity, "Poisoned!", {"color": Color.BROWN})
