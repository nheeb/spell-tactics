extends Node

const HEX_RINGS = preload("res://Effects/HexRings.tscn")
const HEX_COLOR = preload("res://Effects/HexColor.tscn")
const ICON_VISUALS = preload("res://Effects/IconVisuals.tscn")
const ICON_BURST = preload("res://Effects/IconBurst.tscn")
const BILLBOARD_EFFECT = preload("res://Effects/BillboardEffect.tscn")
const BILLBOARD_PROJECTILE = preload("res://Effects/BillboardProjectile.tscn")
const LINE = preload("res://Effects/LineEffect.tscn")
const IMMEDIATE_ARROWS = preload("res://Effects/ImmediateArrows.tscn")
const ENERGY_ORB = preload("res://Effects/EnergyOrb.tscn") 
const ENERGY_ORB_ATTRACTOR = preload("res://Effects/EnergyOrbs/EnergyOrbAttractor.tscn")

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
		EnergyStack.EnergyType.Life:
			return life_color
		EnergyStack.EnergyType.Harmony:
			return harmony_color
		EnergyStack.EnergyType.Flow:
			return flow_color
		EnergyStack.EnergyType.Decay:
			return decay_color
		EnergyStack.EnergyType.Spectral:
			return spectral_color
	printerr("unknown type")
	return Color.RED

@export var energy_icons: Array[Texture]
func type_to_icon(_type) -> Texture:
	match _type:
		EnergyStack.EnergyType.Any:
			return energy_icons[0]
		EnergyStack.EnergyType.Matter:
			return energy_icons[1]
		EnergyStack.EnergyType.Life:
			return energy_icons[2]
		EnergyStack.EnergyType.Harmony:
			return energy_icons[3]
		EnergyStack.EnergyType.Flow:
			return energy_icons[4]
		EnergyStack.EnergyType.Decay:
			return energy_icons[5]
		EnergyStack.EnergyType.Spectral:
			return energy_icons[6]
	printerr("unknown type")
	return energy_icons[0]
