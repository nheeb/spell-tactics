class_name CombatEventLogic extends Object

var combat: Combat
var event: CombatEvent

func on_activate() -> void:
	_on_activate()

func on_advance(round_number: int) -> void:
	_on_advance(round_number)

func on_finish() -> void:
	_on_finish()

func on_show_info() -> void:
	_on_show_info()

func on_hover(hovering: bool) -> void:
	_on_hover(hovering)

func on_click() -> void:
	_on_click()

############################
## Methods for overriding ##
############################

func _on_activate() -> void:
	pass

func _on_advance(round_number: int) -> void:
	pass

func _on_finish() -> void:
	pass

func _on_show_info() -> void:
	pass

func _on_hover(hovering: bool) -> void:
	pass

func _on_click() -> void:
	pass
