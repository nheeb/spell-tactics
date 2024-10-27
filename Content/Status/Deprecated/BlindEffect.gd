class_name BlindEffect extends StatusEffect

## Make persistant vars export so they get serialized automatically since StatusEffect is a Resource
@export var value: int

## make_timed_effect_self_call(method: String, params := []) -> TimedEffect:
## make_timed_effect_entity_call(method: String, params := []) -> TimedEffect:
## You can use those wrapper functions to create timed effects
## (they get added into the combat automatically and are set on EndPhase by default)
## self_remove() is a shortcut for entity.remove_status_effect(get_status_name())

## Name of the status effect
func get_status_name() -> String:
	return "blind"

func get_icon_name() -> String:
	return "blind"

func _init(_value := 3) -> void:
	value = _value

## For overwriting: Logic when status effect enters the game
## This will only be called when the status effect is applied, not when it is loaded
func setup_logic() -> void:
	reduce_acc(value)
	TimedEffect.new_end_phase_trigger_from_callable(self_remove).set_oneshot().register(combat)

## For overwriting: Visual changes when status effect enters the game
func setup_visually() -> void:
	combat.animation.add_staying_effect(VFX.ICON_VISUALS, entity.visual_entity, "blind_icons", {"icon_name": get_icon_name(), "color": Color.GRAY})

## For overwriting: How does the effect change, when the entity would get another instance of the same effect
func extend(other_status: StatusEffect) -> void:
	reduce_acc(other_status.get("value") as int)
	value += other_status.get("value") as int

## For overwriting: Effects on being removed
func on_remove() -> void:
	recover_acc()
	combat.animation.remove_staying_effect(entity.visual_entity, "blind_icons")

func reduce_acc(x: int):
	entity = entity as EnemyEntity
	entity.accuracy -= x

func recover_acc():
	entity = entity as EnemyEntity
	entity.accuracy += value
