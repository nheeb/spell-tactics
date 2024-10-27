class_name CombatEventIcon extends Control

var event: CombatEvent

var texture: Texture:
	set(t):
		texture = t
		%IconSprite.texture = t
var subtext := "":
	set(s):
		subtext = s
		%Label.text = s

var handler := WaitTicketHandler.new()
func get_wait_ticket_handler(): return handler

func animate_highlight(h: bool):
	var ticket = handler.get_ticket()
	if h:
		%HighlightPlayer.play("spin")
	var tween := VisualTime.new_tween()
	tween.tween_property(%Highlight, "scale", Vector2.ONE * (1.0 if h else .01), .5)
	await tween.finished
	if not h:
		%HighlightPlayer.stop()
	ticket.resolve()

func _on_area_2d_mouse_entered() -> void:
	event.hover()

func _on_area_2d_mouse_exited() -> void:
	event.hover(false)
