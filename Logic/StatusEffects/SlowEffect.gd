class_name SlowEffect extends StatusEffect

## Make persistant vars export so they get serialized automatically since StatusEffect is a Resource
@export var last_movement_range: int

## get_reference() returns a StatusEffectReference
## Because of that you can use callables to create TimedEffects
## self_remove() is a shortcut for entity.remove_status_effect(get_status_name())

## Name of the status effect
func get_status_name() -> String:
	return "slow"

## For overwriting: Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func setup_logic() -> void:
	last_movement_range = combat.player.traits.movement_range
	combat.player.traits.movement_range = 1
	var spell_phase_start = combat.get_phase_node(Combat.RoundPhase.Spell).process_start
	TimedEffect.new_from_signal_and_callable(spell_phase_start,self_remove).set_oneshot().register(combat)

## For overwriting: Visual changes when status effect enters the game
func setup_visually() -> void:
	combat.animation.add_staying_effect(VFX.ICON_VISUALS, entity.visual_entity, "%s_icons" % get_status_name(), {"icon_name": "snowflake", "color": Color.AQUA})
	pass

## For overwriting: How does the effect change, when the entity would get another instance of the same effect
func extend(other_status: StatusEffect) -> void:
	pass

## For overwriting: Effects on being removed
func on_remove() -> void:
	combat.animation.remove_staying_effect(entity.visual_entity, "%s_icons" % get_status_name())
	combat.player.traits.movement_range = last_movement_range

