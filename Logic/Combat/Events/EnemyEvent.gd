class_name EnemyEvent extends CombatEvent

func enemy_event_logic() -> EnemyEventLogic:
	return logic as EnemyEventLogic

func enemy_event_type() -> EnemyEventType:
	return type as EnemyEventType

var override_meter_costs := 0
func get_enemy_meter_costs() -> int:
	if override_meter_costs > 0:
		return override_meter_costs
	else:
		return enemy_event_type().enemy_meter_costs

## ACTION
func discover():
	combat.animation.callable(combat.ui.enemy_event_icon.spawn)
	show_info(true)
	combat.animation.wait(1.4)
	await enemy_event_logic().on_discover()
	combat.animation.wait(.7)
	show_info(false)

## ACTION
func activate():
	show_info(true)
	combat.animation.wait(.5)
	combat.animation.callable(combat.ui.enemy_event_icon.activate)
	combat.animation.wait(.5)
	await enemy_event_logic().on_activate()
	combat.animation.wait(.7)
	show_info(false)
	combat.animation.callable(combat.ui.enemy_event_icon.clear)

const DEFAULT_SKULL_TEXTURE = preload("res://Assets/Sprites/Icons/skull.png")
const DEFAULT_GOBLIN_TEXTURE = preload("res://Assets/Sprites/Icons/goblin.png")
func get_active_icon() -> Texture:
	return Utility.array_safe_get(enemy_event_type().icons, 0, false, \
		DEFAULT_GOBLIN_TEXTURE)

func get_inactive_icon() -> Texture:
	if enemy_event_type().unactive_icon:
		return enemy_event_type().unactive_icon
	else:
		return DEFAULT_SKULL_TEXTURE

func show_info(visible := true) -> AnimationObject:
	if visible:
		return combat.animation.callable(combat.ui.enemy_event_info.show_event.bind(self))
	else:
		return combat.animation.callable(combat.ui.enemy_event_info.hide)
