class_name Spell extends Castable

@export var type: SpellType
var logic: SpellLogic
var card: HandCard3D

func serialize() -> SpellState:
	var state := SpellState.new(self)
	return state

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
	update_current_state()

func build_cast_lines():
	super()
	if selected:
		if not is_energy_loaded_fully():
			combat.ui.cast_lines.add("Select missing energy!", Color.ORANGE)
