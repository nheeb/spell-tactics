class_name PlayerCastTargeted extends PlayerCast

var target

func _init(_spell: Spell, _payment: Array[Game.Energy], _target) -> void:
	super(_spell, _payment)
	self.target = _target
	action_string = "Cast targeted %s on %s" % [_spell, _target]
	

func is_valid(combat: Combat) -> bool:
	var super_valid: bool = super(combat)
	# TODO valid target
	# TODO valid range
	return super_valid


func execute(combat: Combat) -> void:
	spell.logic.target = target
	spell.logic.cast(payment)
