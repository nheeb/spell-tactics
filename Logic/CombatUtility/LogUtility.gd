class_name LogUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

var log_lines: Array[String] = []

func add(text: String):
	log_lines.append(text)
	print("Combat Log: %s" % text)
