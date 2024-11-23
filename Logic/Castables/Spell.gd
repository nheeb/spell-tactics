class_name Spell extends Castable

var type: SpellType
var id: SpellID
var logic: SpellLogic
var card: HandCard3D

func _init(_type: SpellType, _combat : Combat = null) -> void:
	type = _type
	combat = _combat
	if combat != null:
		logic = type.logic.new(self)

func get_copy_for_combat(_combat: Combat) -> Spell:
	var spell := Spell.new(type, _combat)
	spell.combat_persistant_properties = combat_persistant_properties.duplicate()
	return spell

func serialize() -> SpellState:
	var state := SpellState.new()
	state.type = type
	state.id = id
	state.combat_persistant_properties = combat_persistant_properties
	state.round_persistant_properties = round_persistant_properties
	return state
	
func _to_string() -> String:
	return type.internal_name

func get_reference() -> SpellReference:
	return SpellReference.new(self)

func get_keywords() -> Array[Keyword]:
	return type.keywords

func get_effect_text() -> String:
	return type.get_effect_text(get_keywords())

func get_costs() -> EnergyStack:
	return logic.get_costs()

func player_has_enough_energy() -> bool:
	var energy := combat.energy.player_energy
	var costs := get_costs()
	return energy.get_possible_payment(costs) != null

func is_selectable() -> bool:
	var enough := player_has_enough_energy()
	var logic_selectable := logic.is_selectable()
	return enough and logic_selectable

func is_energy_loaded_fully() -> bool:
	return not get_card().has_empty_energy_sockets()

func is_castable() -> bool:
	return logic.is_castable() and super.is_castable() and is_energy_loaded_fully()

func select():
	super.select()
	combat.animation.callable(combat.ui.cards3d.pin_card.bind(card))

func deselect():
	super.deselect()
	if combat.ui.cards3d.pinned_card == card:
		combat.animation.callable(combat.ui.cards3d.unpin_card)
	else:
		push_error("Tried to deselect spell which wasnt pinned")

func get_card() -> Card3D:
	return card

func get_logic() -> CastableLogic:
	return logic

func get_type() -> CastableType:
	return type

func on_energy_load():
	combat.animation.callable(update_current_state)

func update_current_state(reset := false):
	super.update_current_state(reset)
	if reset:
		return
	if not get_card():
		return
	update_energy_ui()

func update_energy_ui():
	if not is_energy_loaded_fully():
		combat.ui.error_lines.add("Select missing energy")
