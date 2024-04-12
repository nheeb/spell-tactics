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
