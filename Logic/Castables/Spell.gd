class_name Spell extends Castable

@export var type: SpellType
var logic: SpellLogic
var card: HandCard3D

func serialize() -> SpellState:
	var state := SpellState.new(self)
	return state

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
