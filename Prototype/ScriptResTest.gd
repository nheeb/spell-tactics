extends Node3D

@export var scrpt : Script


func _ready():
	var sss = scrpt.new()
	sss.call("test")
	sss.call("test")
	sss.call("test")
	
	for prop in sss.get_property_list():
		print(prop.name + " " + str(sss.get(prop.name)))
	
	
	var fff = scrpt.new()
	fff.call("test")
	fff.call("test")
	fff.call("test")
	
	scrpt.call("mist")
	scrpt.call("kagge")
