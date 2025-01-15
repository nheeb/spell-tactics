class_name InputUtility extends CombatUtility

###############################
## Processing Player Actions ##
###############################

## Creates the action ticket for a player action. It does not add it to the stack.
func player_action_ticket(action: PlayerAction) -> ActionTicket:
	return ActionTicket.new(
		process_action.bind(action),
		ActionTicket.Type.PlayerAction,
		ActionFlavor.new().add_tag(ActionFlavor.Tag.PlayerAction).finalize(combat)
	)

## ACTION Checks whether an action is valid and executes it.
## CAUTION Don't call this directly. Call combat.action_stack.process_player_action(...) instead.
func process_action(action: PlayerAction) -> void:
	if is_action_blocked(action):
		return
	if action.is_valid(combat):
		await action.execute(combat)
		action.executed.emit()
		update_ui()
	else:
		await action.on_fail(combat)
		action.failed.emit()

func is_action_blocked(action: PlayerAction) -> bool:
	if action._forced:
		return false
	if input_blocked(InputBlockType.Generic):
		return true
	for ibt in action.blocking_types:
		if input_blocked(ibt):
			return true
	return false

## DIRTY TODO Move this somewhere else?
func update_ui():
	combat.ui.update_payable_cards()

######################
## Current Castable ##
######################

var current_castable: Castable

func select_castable(castable: Castable):
	assert(current_castable == null, "This should be cleared to be clean.")
	current_castable = castable
	current_castable.select()

func deselect_castable(castable: Castable = null):
	if current_castable == castable or castable == null:
		current_castable.deselect()
		current_castable = null

#########################################
## Converting signals to PlayerActions ##
#########################################

func connect_with_event_signals() -> void:
	Events.tile_clicked.connect(tile_clicked)
	Events.tile_rightclicked.connect(tile_rightclicked)
	#Events.tile_hovered.connect(tile_hovered)
	PATileHoverUpdate.on_tile_hovered.connect(
		func(tile: Tile):
			combat.action_stack.process_player_action(PATileHoverUpdate.new(tile, true))
	)
	Events.tile_unhovered.connect(tile_unhovered)
	Events.card_hovered.connect(card_hovered)
	Events.card_selected.connect(card_selected)
	Events.energy_orb_clicked.connect(energy_orb_clicked)
	Events.energy_socket_clicked.connect(energy_socket_clicked)
	Events.pinned_card_clicked.connect(pinned_card_clicked)
	Events.pinned_card_rightclicked.connect(pinned_card_rightclicked)

func tile_unhovered(tile: Tile):
	combat.action_stack.process_player_action(PATileHoverUpdate.new(tile, false))

func tile_clicked(tile: Tile) -> void:
	combat.action_stack.process_player_action(PASelectTile.new(tile))
	combat.action_stack.process_player_action(PAInstantDrain.new(tile))

func tile_rightclicked(tile: Tile) -> void:
	combat.action_stack.process_player_action(PADeselectTile.new(tile))

func card_hovered(card: Card3D) -> void:
	pass # TODO Nitai Connect this to some PA

func card_selected(card: Card3D) -> void:
	combat.action_stack.process_player_action(PASelectCastable.new(card.get_castable()))

func energy_orb_clicked(orb : EnergyOrb):
	combat.action_stack.process_player_action(PALoadEnergy.new(orb))

func energy_socket_clicked(socket : HandCardEnergySocket):
	combat.action_stack.process_player_action(PAUnloadSocket.new(socket))

func pinned_card_clicked(card: Card3D):
	combat.action_stack.process_player_action(PAActivateCastable.new(true))

func pinned_card_rightclicked(card: Card3D):
	combat.action_stack.process_player_action(PADeselectCastable.new())

#####################
## Process Hotkeys ##
#####################

func process_active_hotkeys():
	if Input.is_action_just_pressed("movement_active"): # can only right-click move if no castable is selected
		if current_castable == null:
			combat.action_stack.process_player_action(PASelectCastable.new(combat.actives[0]))
		elif combat.input.current_castable == combat.actives[0]:
			combat.action_stack.process_player_action(PADeselectCastable.new())
	if Input.is_action_just_pressed("drain_active"):
		if not combat.input.current_castable == combat.actives[1]:
			combat.action_stack.process_player_action(PASelectCastable.new(combat.actives[1]))
		else:
			combat.action_stack.process_player_action(PADeselectCastable.new())
	if Input.is_action_just_pressed("melee_active"):
		if not combat.input.current_castable == combat.actives[2]:
			combat.action_stack.process_player_action(PASelectCastable.new(combat.actives[2]))
		else:
			combat.action_stack.process_player_action(PADeselectCastable.new())
	if Input.is_action_just_pressed("focus_on_player") and combat.player != null:
		combat.action_stack.process_player_action(PACamFocusPlayer.new())

func _process(delta: float) -> void:
	if not Game.LEVEL_EDITOR:
		process_active_hotkeys()

####################
## Blocking Input ##
####################

## Enum of different situations that can cause Input Blocking.
enum InputBlockType {
	Any, ## This doesn't really exist. It's rather a shortcut to test for every type.
	Generic, ## This blocks all action in general. (before testing for individual blocks)
	OrbTransition, ## Certain Action should be blocked if an orb is flying towards a socket.
	EnemyPhase, ## Most Actions should be blocked when the enemy phase is played.
}

## Internal Dictionary to keep track of the Input Blocks.
## {InputBlockType -> Number of Blocks (int)}
var input_blocks : Dictionary = {}

## Returns whether a InputBlockType is blocked.
func input_blocked(type: InputBlockType) -> bool:
	if type == InputBlockType.Any:
		return Utility.array_sum(input_blocks.values(), 0) > 0
	return input_blocks.get_or_add(type, 0) > 0

## Blocks or unblocks the input for a certain type. Blocking here works with numbers,
## so each positive Block needs exactly one negative Block to resolve.
func block_input(type: InputBlockType, block := true) -> void:
	type = type if type != InputBlockType.Any else InputBlockType.Generic
	input_blocks[type] = input_blocks.get(type, 0) + sign(float(block) - .5)
