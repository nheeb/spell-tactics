class_name VFXUtils extends Node

const HEX_RINGS = preload("res://VFX/Effects/HexRings.tscn")
const HEX_COLOR = preload("res://VFX/Effects/HexColor.tscn")
const ICON_VISUALS = preload("res://VFX/Effects/IconVisuals.tscn")
const ICON_BURST = preload("res://VFX/Effects/IconBurst.tscn")
const ICON_CYCLE = preload("res://VFX/Effects/CirclingIcons.tscn")
const BILLBOARD_EFFECT = preload("res://VFX/Effects/BillboardEffect.tscn")
const BILLBOARD_PROJECTILE = preload("res://VFX/Effects/BillboardProjectile.tscn")
const LINE = preload("res://VFX/Effects/LineEffect.tscn")
const IMMEDIATE_ARROWS = preload("res://VFX/Effects/ImmediateArrows.tscn")
const ENERGY_ORB = preload("res://VFX/Effects/EnergyOrbs/EnergyOrb.tscn") 
const ENERGY_ORB_ATTRACTOR = preload("res://VFX/Effects/EnergyOrbs/EnergyOrbAttractor.tscn")

const DRAIN_DURATION: float = 0.8

@export var any_color: Color
@export var matter_color: Color
@export var life_color: Color
@export var harmony_color: Color
@export var flow_color: Color
@export var decay_color: Color
@export var spectral_color: Color
func type_to_color(_type) -> Color:
	match _type:
		EnergyStack.EnergyType.Any:
			return any_color
		EnergyStack.EnergyType.Matter:
			return matter_color
		EnergyStack.EnergyType.Empty:
			return life_color
		EnergyStack.EnergyType.Harmony:
			return harmony_color
		EnergyStack.EnergyType.Flow:
			return flow_color
		EnergyStack.EnergyType.Decay:
			return decay_color
		EnergyStack.EnergyType.Spectral:
			return spectral_color
	push_error("unknown type")
	return Color.RED

@export var energy_icons: Array[Texture]
func type_to_icon(_type) -> Texture:
	match _type:
		EnergyStack.EnergyType.Any:
			return energy_icons[0]
		EnergyStack.EnergyType.Matter:
			return energy_icons[1]
		EnergyStack.EnergyType.Empty:
			return energy_icons[2]
		EnergyStack.EnergyType.Harmony:
			return energy_icons[3]
		EnergyStack.EnergyType.Flow:
			return energy_icons[4]
		EnergyStack.EnergyType.Decay:
			return energy_icons[5]
		EnergyStack.EnergyType.Spectral:
			return energy_icons[6]
	push_error("unknown type")
	return energy_icons[0]

func get_icon_from_name(icon_name) -> Texture:
	if icon_name is Texture:
		return icon_name
	if icon_name == "" or icon_name == null:
		return null
	return load("res://Assets/Sprites/Icons/%s.png" % icon_name)
