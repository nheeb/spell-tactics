class_name CombatUI extends Control

var combat : Combat
var selected_spell: Spell
var actives: Array[Active]

@onready var cards3d: Cards3D = %Cards3D
@onready var timeline: TimelineUI = %Timeline
@onready var error_lines: StatusLines = %ErrorLines
@onready var event_icons: CombatEventIcons = %CombatEventIcons
@onready var event_info: CombatEventInfo = %CombatEventInfo
@onready var enemy_event_info: CombatEventInfo = %EnemyEventInfo
@onready var enemy_event_icon: EnemyEventIcon = %EnemyEventIcon

var ticket_handler := WaitTicketHandler.new()
func get_wait_ticket_handler(): return ticket_handler

var buttons: Array[ActiveButtonWithUses] = []

func setup(_combat: Combat):
	self.combat = _combat
	# Update UI
	for spell in self.combat.hand:
		cards3d.add_card(spell)
	$GameOverText.visible = false

	# set actives
	actives = _combat.actives
	_combat.round_ended.connect(next_round)
	initialize_active_buttons(actives)
	update_payable_cards()
	cards3d.setup(_combat)

	# Build timeline
	# TODO Delete Timeline Code
	# %Timeline.build_timeline_from_log(combat.log)

func next_round(current_round: int):
	pass

func _on_next_pressed():
	combat.action_stack.process_player_action(PAPass.new())

func deselect_card():
	selected_spell = null

func set_status(text: String):
	$Status.text = text

func set_drains_left(x: int) -> void:
	$Drains.text = "Drains left: %s" % x

const ACTIVE_BUTTON = preload("res://UI/CombatUI/ActiveButtonWithUses.tscn")

func initialize_active_buttons(new_actives: Array[Active]):
	actives = new_actives
	var i = 0
	for active in actives:
		#var active_button = buttons[i]
		var active_button = ACTIVE_BUTTON.instantiate()
		active.button = active_button
		active_button.name = "ActiveButton%d" % i
		active_button.active = active
		$Actives.add_child(active_button)
		
		active_button.position = get_node("Actives/ActivePos%d" % (i+1)).position
		active_button.button.pressed.connect(_on_active_button_pressed.bind(i))
		active.got_locked.connect(_on_active_locked.bind(i))
		active.got_unlocked.connect(_on_active_unlocked.bind(i))
		active_button.button.disabled = not active.unlocked
		active_button.owner = self

		i += 1
		
func disable_actions():
	# TODO disable card selection / others?
	pass

func set_current_energy(energy: EnergyStack):
	update_payable_cards()

func update_payable_cards():
	for hand_card in cards3d.hand_cards:
		hand_card.set_distort(not hand_card.get_castable().is_selectable())

func _ready() -> void:
	deselect_card()
	%EnemyArrow.visible = false
	Game.got_paused.connect(on_game_paused)
	Game.got_unpaused.connect(on_game_unpaused)

func on_game_paused():
	hide()
	
func on_game_unpaused():
	show()

func _on_active_button_pressed(i: int) -> void:
	combat.action_stack.process_player_action(PASelectCastable.new(actives[i]))
	
func _on_active_unlocked(i: int) -> void:
	var active_button = $Actives.get_node("ActiveButton%d" % i)
	active_button.button.disabled = false
	
func _on_active_locked(i: int) -> void:
	var active_button = $Actives.get_node("ActiveButton%d" % i)
	active_button.button.disabled = true

func _on_button_entered() -> void:
	Game.world.get_node("%MouseRaycast").disabled = true

func _on_button_exited() -> void:
	Game.world.get_node("%MouseRaycast").disabled = false

func show_victory(text: String) -> void:
	Game.combat_to_review = combat
	ActivityManager.substitute(PostCombatActivity.new())

func show_game_over(text: String) -> void:
	Game.combat_to_review = combat
	ActivityManager.substitute(DeathActivity.new())

func set_enemy_meter(value: int) -> void:
	print("set enemy meter ", value)
	ticket_handler.get_ticket().resolve_on(%EnemyEventIcon.transition_done)
	%EnemyEventIcon.transition_to_fill(value)

func set_enemy_meter_max(value: int, event : EnemyEvent = null) -> void:
	%EnemyEventIcon.set_max_fill(value, event)

func set_enemy_meter_event(event: EnemyEvent) -> void:
	%EnemyEventIcon.set_event(event)
