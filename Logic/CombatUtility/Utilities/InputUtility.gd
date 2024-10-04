class_name InputUtility extends CombatUtility

signal action_executed(action: PlayerAction)
signal action_failed(action: PlayerAction)

var input_blocked := false

## Checks whether an action is valid and executes it.
func player_action_ticket(action: PlayerAction, force_action := false) -> ActionTicket:
	return ActionTicket.new(process_action.bind(action, force_action))

## ACTION
## Checks whether an action is valid and executes it.
func process_action(action: PlayerAction, force_action := false) -> void:
	if not (is_taking_actions() or force_action):
		return
	var valid := action.is_valid(combat)
	action.log_me(combat, valid)
	if valid:
		await action.execute(combat)
		# deacted anim queue because action stack takes care of that
		# combat.animation.play_animation_queue()
		update_ui()
		action.executed.emit()
		action_executed.emit(action)
	else:
		await action.on_fail(combat)
		action.failed.emit()
		action_failed.emit(action)

var current_castable : Castable

func select_castable(castable: Castable):
	current_castable = castable
	current_castable.select()
	# remove all tile highlights

func deselect_castable(castable: Castable = null):
	if current_castable == castable or castable == null:
		current_castable.deselect()
		current_castable = null

func is_taking_actions() -> bool:
	var t := not input_blocked and combat.current_phase == Combat.RoundPhase.Spell
	return t

func update_ui():
	combat.ui.update_payable_cards()

	
	
func tile_unhovered(tile: Tile):
	combat.action_stack.process_player_action(PAUnhoverTile.new(tile))

func tile_clicked(tile: Tile) -> void:
	combat.action_stack.process_player_action(PASelectTile.new(tile))
	combat.action_stack.process_player_action(PAInstantDrain.new(tile))

func tile_rightclicked(tile: Tile) -> void:
	combat.action_stack.process_player_action(PADeselectTile.new(tile))

func card_hovered(card: HandCard3D) -> void:
	pass # TODO Nitai Connect this to some PA

func card_selected(card: HandCard3D) -> void:
	combat.action_stack.process_player_action(PASelectCastable.new(card.get_castable()))

func energy_orb_clicked(orb : EnergyOrb):
	combat.action_stack.process_player_action(PALoadEnergy.new(orb))

func energy_socket_clicked(socket : HandCardEnergySocket):
	combat.action_stack.process_player_action(PAUnloadSocket.new(socket))

func pinned_card_clicked(card: Card3D):
	combat.action_stack.process_player_action(PAActivateCastable.new(true))

func pinned_card_rightclicked(card: Card3D):
	combat.action_stack.process_player_action(PADeselectCastable.new())

func connect_with_event_signals() -> void:
	Events.tile_clicked.connect(tile_clicked)
	Events.tile_rightclicked.connect(tile_rightclicked)
	#Events.tile_hovered.connect(tile_hovered)
	PAHoverTile.on_tile_hovered.connect(func(tile): combat.action_stack.process_player_action(PAHoverTile.new(tile)))
	Events.tile_unhovered.connect(tile_unhovered)
	Events.card_hovered.connect(card_hovered)
	Events.card_selected.connect(card_selected)
	Events.energy_orb_clicked.connect(energy_orb_clicked)
	Events.energy_socket_clicked.connect(energy_socket_clicked)
	Events.pinned_card_clicked.connect(pinned_card_clicked)
	Events.pinned_card_rightclicked.connect(pinned_card_rightclicked)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("focus_on_player") and combat.player != null:
		combat.animation.camera_reach(combat.player.visual_entity)
		combat.animation.play_animation_queue()
