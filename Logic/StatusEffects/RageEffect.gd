class_name RageEffect extends StatusEffect

## Make persistant vars export so they get serialized automatically since StatusEffect is a Resource

## get_reference() returns a StatusEffectReference
## Because of that you can use callables to create TimedEffects
## self_remove() is a shortcut for entity.remove_status_effect(get_status_name())

## Name of the status effect
func get_status_name() -> String:
	return "rage"

## Name of the icon
func get_icon_name() -> String:
	return "axe"

## For overwriting: Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func setup_logic() -> void:
	var enemy = entity as EnemyEntity
	if enemy:
		TimedEffect.new_from_signal_and_callable(enemy.regular_action_done, enemy.do_action) \
			.set_oneshot().extra_last_callable(self_remove).register(combat)

## For overwriting: Visual changes when status effect enters the game
func setup_visually() -> void:
	combat.animation.add_staying_effect(VFX.ICON_VISUALS, entity.visual_entity, \
		"%s_icons" % get_status_name(), {"icon_name": get_icon_name(), "color": Color.HOT_PINK})
	pass

## For overwriting: How does the effect change, when the entity would get another instance of the same effect
func extend(other_status: StatusEffect) -> void:
	pass

## For overwriting: Effects on being removed
func on_remove() -> void:
	combat.animation.remove_staying_effect(entity.visual_entity, "%s_icons" % get_status_name())
	pass
