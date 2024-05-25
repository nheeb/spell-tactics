class_name Spell extends Castable

var type: SpellType
var id: SpellID
var logic: SpellLogic
var visual_representation: HandCard2D
var card: HandCard3D
var event_logic: EventSpellLogic:
	get:
		if not type.is_event_spell:
			pass
			#printerr("Trying to get an EventSpellLogic from a non event spell")
		return logic as EventSpellLogic

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
	return energy.get_possible_payment(get_costs()) != null

func is_selectable() -> bool:
	return player_has_enough_energy() and logic.is_selectable()

func select():
	combat.ui.cards3d.pin_card(card)

func deselect():
	if combat.ui.cards3d.pinned_card == card:
		combat.ui.cards3d.unpin_card()
	else:
		printerr("Tried to deselect spell which wasnt pinned")

func get_card() -> Card3D:
	return card
