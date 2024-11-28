class_name CombatEventLogic extends CombatLogic

var event: CombatEvent:
	get:
		return combat_object as CombatEvent
	set(x):
		push_error("Do not set this.")

func on_activate() -> void:
	_on_activate()

## ACTION
func on_advance(round_number: int) -> void:
	await _on_advance(round_number)

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

## ACTION
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
