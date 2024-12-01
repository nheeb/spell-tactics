class_name CombatEventType extends CombatObjectType

## Effect text shown on the card
@export_multiline var effect_text: String

enum OrderPrio {First = 5, Middle = 10, Last = 15}
@export var order: OrderPrio = OrderPrio.Middle

## Icon (and variants) that will be shown in the top screen when active.
@export var icons: Array[Texture]

## If true, the event won't be shown in the current event icons.
@export var hidden_icon := false
## If true, the effect text will be shown during the advance / main effect.
@export var show_info_on_advancing := true
## If true, the effect text will be shown during the "creation".
@export var show_info_on_activation := false
## If the value is > 0, the event will finish automatically after X rounds.
@export var max_duration := 0

## Logic script
var logic: Script

const DEFAULT_ICON = preload("res://Assets/Sprites/Icons/circle.png")
func get_icon(index := 0) -> Texture:
	return Utility.array_safe_get(icons, index, false, DEFAULT_ICON)

func create_base_object() -> CombatEvent:
	var event : CombatEvent
	if self is EnemyEventType:
		event = EnemyEvent.new()
	else:
		event = CombatEvent.new()
	return event

func create_event(combat: Combat, props := {}) -> CombatEvent:
	return create(combat, props) as CombatEvent
