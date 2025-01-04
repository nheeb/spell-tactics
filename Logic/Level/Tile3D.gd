class_name Tile3D extends Node3D

var tile: Tile

@onready var level: Level = get_parent() as Level
var combat: Combat:
	get:
		return level.combat
@onready var highlight: Highlight = $Highlight

func set_highlight(type: Highlight.Type, active: bool):
	if active:
		$Highlight.enable_highlight(type)
	else:
		$Highlight.disable_highlight(type)

func _on_hover_timer_timeout() -> void:
	tile.hovering = true
	tile.combat.action_stack.process_player_action(
		PATileHoverUpdate.new(tile, true, true)
	)

func _to_string() -> String:
	return name

func _ready() -> void:
	pass

####################
## Visual Effects ##
####################

## TBD Maybe we should make a new base class for CombatNode3D for the
## following section.

## Ticket Handler and getter for all kinds of animation
var ticket_handler := WaitTicketHandler.new()
func get_wait_ticket_handler() -> WaitTicketHandler:
	return ticket_handler

var visual_effects := {}

func add_visual_effect(id: String, effect: StayingVisualEffect) -> void:
	if id in visual_effects:
		push_error("VisualEntity already has effect %s" % id)
	visual_effects[id] = effect
	add_child(effect)

func remove_visual_effect(id: String) -> void:
	if id in visual_effects.keys():
		var effect := (visual_effects[id] as StayingVisualEffect)
		ticket_handler.get_ticket().resolve_on(effect.effect_died)
		effect.on_effect_end()
		visual_effects.erase(id)
	else:
		push_error("VisualEntity has no effect %s" % id)
