class_name CombatEvent extends Object

var combat: Combat
var id: CombatEventID
var type: CombatEventType
var logic: CombatEventLogic

## Active CombatEvents will be advaced each round by the EventUtility.
var active: bool = false
## Finished events cannot be reactivated. (Create new events instead)
var finished: bool = false

## Number of rounds the event was advanced.
var rounds: int

## All persistant properties of the event should be saved here for serialization.
## (Only Primitives and Resources. Use References for anything complex.)
var persistant_properties := {}

## Reference to the icon in CombatUI
var icon: CombatEventIcon

## Sets active to true and creates the UI icon
func activate() -> void:
	assert(not (finished or active))
	active = true
	rounds = 0
	create_icon()
	update_ui_icon()
	logic.on_activate()

## Triggers the main effect of the event.
## Will be called in every end step as long as the event is active.
func advance() -> void:
	rounds += 1
	highlight_icon(true)
	logic.on_advance(rounds)
	highlight_icon(false)

## Sets active to false. The event won't be advanced further and can't be
## reativated.
func finish() -> void:
	active = false
	finished = true
	logic._on_finish()
	remove_icon()

## Shows the effect text in UI as animation in the AQ.
func show_info(visible := true) -> AnimationObject:
	if visible:
		return combat.animation.callable(combat.ui.event_info.show_event.bind(self))
	else:
		return combat.animation.callable(combat.ui.event_info.hide)

func hover(hovering := true) -> void:
	show_info(hovering)
	logic.on_hover(hovering)

## Creates an invisble icon node in the UI and connects it to the event.
func create_icon():
	icon = combat.ui.event_icons.create_icon(self)

func remove_icon():
	assert(icon)
	icon.queue_free()
	icon = null

## Changes visible attributes of the icon as AQ animation.
func update_ui_icon(visible := true, texture : Texture = type.get_icon(),\
				subtext := "") -> AnimationObject:
	assert(icon)
	if type.hidden_icon: visible = false
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
