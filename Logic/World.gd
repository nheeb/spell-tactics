class_name World extends Node3D

const COMBAT = preload("res://Logic/Combat.tscn")
const COMBAT_UI = preload("res://UI/CombatUI.tscn")

var level : Level
var camera : Camera3D
var ui_root : Node
@onready var combat : Combat
@onready var combat_ui : CombatUI
@export var debug_ui: Control
@export var popup_handler: Control

var relative_motion: Vector2:
	set(m):
		$GameCamera.relative_motion = m
		relative_motion = m

signal combat_changed (combat : Combat)

func _ready() -> void:
	Game.world = self

func load_combat_from_path(level_path: String) -> void:
	var combat_state: CombatState = load(level_path) as CombatState
	load_combat_from_state(combat_state)

func load_combat_from_state(combat_state: CombatState) -> void:
	# If we always create a new ScreenCombat for every Combat (which I think
	# we should) then some of the following lines could be cut & simplified
	
	# Take the deck from the current adventure
	combat_state.deck_states = Adventure.deck_states
	
	# Create combat
	combat = combat_state.deserialize()
	self.combat = combat # What?
	add_child(combat)
	
	# Add level to tree
	level = combat.level
	add_child(combat.level)
	
	# Apparently that's only for notifying the PopUpHandler
	combat_changed.emit(combat)
	
	# construct references to ui_root which lives outside this 3d viewport
	# ui_root/combat_ui and ui_root/debug_ui
	ui_root = get_tree().get_first_node_in_group("ui_root") # This seems kinda weird to me
	combat_ui = COMBAT_UI.instantiate()
	ui_root.add_child(combat_ui)
	var i = ui_root.get_node("DebugUI").get_index()
	ui_root.move_child(combat_ui, ui_root.get_node("DebugUI").get_index())
	# TODO nitai remove cursed code
	
	camera = get_node("GameCamera/AnglePivot/ZoomPivot/Smoothing/Camera3D")
	
	# Connect combat to UI & Cam
	await get_tree().process_frame

	
	# Do initial phase process (if any)
	combat.connect_with_ui_and_camera(combat_ui, $GameCamera)
	combat.setup()

	combat.process_initial_phase()
	
	# Play initial animations
	combat.animation.play_animation_queue()
	
	# Connect the raycast & start pop up handler
	# await get_tree().process_frame
	# FIXME looser coupling World with Cards3D and Combat would be preferable
	%MouseRaycast.cards3d = combat_ui.cards3d
	%MouseRaycast.combat = combat
	%MouseRaycast.enabled = true
	
	popup_handler.start()

#func _reset_combat():
	#if combat == null:
		#return
	#remove_child(combat)
	#remove_child(combat.level)
	#ui_root.remove_child(combat_ui)
	#popup_handler.reset()
#
#func _exit_tree():
	#call_deferred("_reset_combat")

func _on_show_debug_pressed() -> void:
	debug_ui.get_node("List").visible = not debug_ui.get_node("List").visible
	if debug_ui.get_node("List").visible:
		debug_ui.get_node("ShowDebug").text = "Hide Debug"
	else:
		debug_ui.get_node("ShowDebug").text = "Show Debug"

func set_active() -> void:
	camera.make_current()
