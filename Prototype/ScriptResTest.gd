extends Node3D

## Returns the first substring between left and right
func string_beween(s: String, left: String, right: String) -> String:
	if left not in s or right not in s: return ""
	return s.split(left)[1].split(right)[0]

## Returns the method names of methods actually written in the script
func script_get_actual_method_names(script: Script) -> Array[String]:
	var a: Array[String] = []
	a.append_array(Array(script.source_code.split("\n")).filter(
		func (x: String): return x.strip_edges().begins_with("func ")
	).map(
		func (x: String): return string_beween(x.strip_edges(), "func ", "(")
	).filter(
		func (x: String): return not x.is_empty()
	))
	return a

func _ready() -> void:
	#get_method_list()
	#print(PoisonEffect.new().get_script().get_method_list().map(
		#func (x): return x["name"]
	#))
	var script := load("res://Spells/AllStatusEffects/Poison.gd") as Script
	#print(script.get_script_method_list().filter(
		#func (x): return x not in script.get_base_script().get_script_method_list()
	#).map(
		#func (x): return x["name"]
	#))

	print(script_get_actual_method_names(script))
