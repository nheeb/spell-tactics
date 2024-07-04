extends PlayerAction

var selected_active: Spell

func _init(selected: Spell) -> void:
	selected_active = selected
	action_string = "Select active %s" % selected
	printerr("Using deprecated PlayerAction %s" % action_string)

