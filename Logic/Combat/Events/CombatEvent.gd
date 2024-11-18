class_name CombatEvent extends CombatObject

var type: CombatEventType
var logic: CombatEventLogic

## The event's parameters based on type.default_params. [br]
## { ParamName (String) -> Value (something serializable) }
#var params := {}

## Active CombatEvents will be advaced each round by the EventUtility.
var active: bool = false
## Finished events cannot be reactivated. (Create new events instead)
var finished: bool = false
var icons_removed: bool = false

## Number of rounds the event was advanced.
var rounds: int

## All persistant properties of the event should be saved here for serialization.
## (Only Primitives and Resources. Use References for anything complex.)
#var persistant_properties := {}

## Reference to the icon in CombatUI
var icon: CombatEventIcon

## Sets active to true and creates the UI icon
func activate() -> void:
	assert(not (finished or active))
	active = true
	rounds = 0
	create_icon()
	update_ui_icon()
	if type.show_info_on_activation:
		show_info(true)
	logic.on_activate()
	if type.show_info_on_activation:
		show_info(false)

## Triggers the "main effect" of the event.
## Will be called in every end step as long as the event is active.
## This will also remove the icon if the event is finished afterwards.
func advance() -> void:
	rounds += 1
	highlight_icon(true)
	if type.max_duration > 0:
		if rounds >= type.max_duration:
			highlight_icon(false)
			combat.animation.wait(.6)
			finish_and_remove_icon()
			return
	if type.show_info_on_advancing:
		show_info(true)
		combat.animation.wait(.6)
	logic.on_advance(rounds)
	if type.show_info_on_advancing:
		show_info(false)
	highlight_icon(false)
	if finished and not icons_removed:
		remove_icon()

## Sets active to false. The event won't be advanced further and can't be
## reativated. This won't remove the icon directly.
func finish() -> void:
	active = false
	finished = true
	logic._on_finish()

func finish_and_remove_icon():
	finish()
	remove_icon()

## Shows the effect text in UI as animation in the AQ.
func show_info(visible := true) -> AnimationObject:
	if visible:
		return combat.animation.callable(combat.ui.event_info.show_event.bind(self))
	else:
		return combat.animation.callable(combat.ui.event_info.hide)

## Is called when the player hovers over the event icon.
func hover(hovering := true) -> void:
	show_info(hovering)
	logic.on_hover(hovering)
	combat.animation.play_animation_queue()

## Is called when the player clicks on the event icon.
func click() -> void:
	logic.on_click()

## Creates an invisble icon node in the UI and connects it to the event.
func create_icon():
	icon = combat.ui.event_icons.create_icon(self)

func remove_icon():
	if not icons_removed:
		icons_removed = true
		combat.animation.callable(
			func ():
				assert(icon)
				icon.queue_free()
				icon = null
		)

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
	var state := CombatEventState.new()
	state.id = id
	state.type = type
	#state.params = params
	state.active = active
	state.finished = finished
	state.rounds = rounds
	#state.persistant_properties = persistant_properties
	return state

func get_effect_text() -> String:
	return type.effect_text + data.get("extra_text", "")
