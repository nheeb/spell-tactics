class_name CombatEvent extends Object

var combat: Combat
var id: CombatEventID
var type: CombatEventType
var logic: CombatEventLogic

## Active CombatEvents will be advaced each round by the EventUtility.
var active: bool = false

## Rounds since the event was activated.
var rounds: int

## All persistant properties of the event should be saved here for serialization.
## (Only Primitives and Resources. Use References for anything complex.)
var persistant_properties := {}

## Reference to the icon in CombatUI
var icon: CombatEventIcon

func advance() -> void:
	rounds += 1
	highlight_icon(true)
	logic.on_advance(rounds)
	highlight_icon(false)

func activate() -> void:
	active = true
	rounds = 0
	update_ui_icon()
	advance()

func finish() -> void:
	active = false

func is_active() -> bool:
	return active

func show_info(visible := true) -> AnimationObject:
	return null

func hover(hovering := true) -> void:
	logic.on_hover()

func create_icon():
	icon = combat.ui.event_icons.create_icon(self)

func update_ui_icon(visible := true, texture := type.get_icon(), subtext := "")\
													-> AnimationObject:
	assert(icon)
	var anims := []
	anims.append(combat.animation.property(icon, "visible", visible))
	anims.append(combat.animation.property(icon, "texture", texture))
	anims.append(combat.animation.property(icon, "subtext", subtext))
	return combat.animation.reappend_as_subqueue(anims)

func highlight_icon(highlight := true) -> AnimationObject:
	assert(icon)
	return combat.animation.callable(icon.animate_highlight.bind(highlight))

func serialize() -> CombatEventState:
	return CombatEventState.new()

func get_reference() -> CombatEventReference:
	return null

func get_effect_text() -> String:
	return type.effect_text
