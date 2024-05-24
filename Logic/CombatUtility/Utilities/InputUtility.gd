class_name InputUtility extends CombatUtility

signal performed_action(action: PlayerAction)

## returns whether it is valid
func process_action(action: PlayerAction) -> bool:
	if action.is_valid(combat):
		print("Doing Player Action: %s" % action.action_string)
		action.execute(combat)
		performed_action.emit(action)
		combat.animation.play_animation_queue()
		combat.ui.update_payable_cards()
		return true
	else:
		# should we throw an error msg here or will this happen in normal play?
		# printerr("Invalid Player Action: %s" % action.action_string)
		action.on_fail(combat)
		return false

func tile_hovered(tile: Tile) -> void:
	combat.get_current_phase_node().tile_hovered(tile)

func tile_clicked(tile: Tile) -> void:
	combat.get_current_phase_node().tile_clicked(tile)

func card_hovered(card: HandCard3D) -> void:
	combat.get_current_phase_node().card_hovered(card)

func connect_with_event_signals() -> void:
	Events.tile_clicked.connect(tile_clicked)
	Events.tile_hovered.connect(tile_hovered)
	Events.card_hovered.connect(card_hovered)



# focus player
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("focus_on_player"):
		combat.animation.camera_reach(combat.player.visual_entity)
		combat.animation.play_animation_queue()
