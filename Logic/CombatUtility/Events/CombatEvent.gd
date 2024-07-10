class_name CombatEvent extends Object

var type: CombatEventType
var logic: CombatEventLogic
var active: bool

func advance() -> void:
	pass

func begin() -> void:
	pass

func is_finished() -> bool:
	return false

func show_card(visible := true) -> void:
	pass

func update_ui_icon() -> void:
	pass

func serialize() -> CombatEventState:
	return CombatEventState.new()
