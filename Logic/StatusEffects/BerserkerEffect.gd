class_name BerserkerEffect extends StatusEffect

## Make persistant vars export so they get serialized automatically since StatusEffect is a Resource

@export var length := 2

## make_timed_effect_self_call(method: String, params := []) -> TimedEffect:
## make_timed_effect_entity_call(method: String, params := []) -> TimedEffect:
## You can use those wrapper functions to create timed effects
## (they get added into the combat automatically and are set on EndPhase by default)
## self_remove() is a shortcut for entity.remove_status_effect(get_status_name())

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
	make_meele_two_uses()
	make_timed_effect_self_call("advance")

## For overwriting: Visual changes when status effect enters the game
func setup_visually() -> void:
	combat.animation.add_staying_effect(VFX.ICON_VISUALS, entity.visual_entity, "berserker_icons", {"icon_name": get_icon_name(), "color": Color.ORANGE})

## For overwriting: How does the effect change, when the entity would get another instance of the same effect
func extend(other_status: StatusEffect) -> void:
	pass

## For overwriting: Effects on being removed
func on_remove() -> void:
	var melee_attacks = combat.actives.filter(func(x): return "Melee" in x.type.pretty_name)
	for melee in melee_attacks:
		melee.uses_left = 0
	combat.animation.remove_staying_effect(entity.visual_entity, "berserker_icons")

func advance() -> void:
	length -= 1
	if length == 0:
		self_remove()
	else:
		make_meele_two_uses()
		make_timed_effect_self_call("advance")

func make_meele_two_uses():
	var melee_attacks = combat.actives.filter(func(x): return "Melee" in x.type.pretty_name)
	for melee in melee_attacks:
		melee.uses_left = 2