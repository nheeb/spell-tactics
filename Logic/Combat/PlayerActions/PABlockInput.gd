class_name PABlockInput extends PlayerAction

var type: InputUtility.InputBlockType
var block := true

func _init(_type := InputUtility.InputBlockType.Generic, _block := true) -> void:
	type = _type
	block = _block
	action_string = ("Block Input" if block else "Unblock Input") + (" %s" % type)

func execute(combat: Combat) -> void:
	combat.input.block_input(type, block)
