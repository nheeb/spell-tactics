class_name TestReadyInit extends Node

var normal_var : int = 10
@onready var onready_var : int = 50

func _init() -> void:
	test_print("init")
	
func test_print(s):
	print(info_text(s))
	if get_parent() is TestReadyInit:
		print("[[[", get_parent().info_text(s), "]]]")
	else:
		print("[[[", get_parent(), "]]]")

func info_text(s):
	return "%s: %s | %s & %s" % [name, s, normal_var, onready_var]

func _ready() -> void:
	test_print("ready")
