class_name EntityStatus extends Resource

@export var type: EntityStatusType
@export var data := {}
@export var is_logic_setup_done := false

var logic: EntityStatusLogic

func _init(_type: EntityStatusType = null) -> void:
	type = _type

func setup(entity: Entity, _data := {}):
	type._on_load()
	data.merge(type.default_data, true)
	data.merge(_data, true)
	logic = type.logic_script.new() as EntityStatusLogic
	logic.entity = entity
	logic.combat = entity.combat
	logic.status = self
	if not is_logic_setup_done:
		logic._setup_logic()
		is_logic_setup_done = true
	logic._setup_visually()

func get_status_name() -> String:
	return type.internal_name
