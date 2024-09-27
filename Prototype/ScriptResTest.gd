extends Node3D

@export_range(0, 1, 0.1) var flack: int = 1

@export var hello: String = "world"

var test = ["ast", "mast", "past"]

func mist():
	pass

signal msst

var aa : Array[AnimationObject]

var type_signals: Dictionary
func _ready() -> void:
	var b = CombatNodeReference.new("uwu") in [CombatNodeReference.new("uwu")]
	print("!!!")
	print(b)
	#for k in LogEntry.Type.keys():
		#k = k as String
		#var t = LogEntry.Type.get(k)
		#var new_sig = Signal()
		#type_signals[t] = new_sig
	#print(type_signals)
	#print("!")
	#type_signals[LogEntry.Type.Info].connect(print_1)
	#type_signals[LogEntry.Type.Info].emit(1)
		

func print_1(x):
	print("%s" % str(x+1))
