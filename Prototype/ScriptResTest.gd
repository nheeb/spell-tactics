extends Node3D


var test = ["ast", "mast", "past"]

func mist():
	pass

signal msst

var aa : Array[AnimationObject]

func _ready() -> void:
	for c in [misse, pisse, misse]:
		var x = null
		print("0")
		x = await c.call()
		print("1")
		print(x)
		print("")


func misse():
	print("A")
	await get_tree().create_timer(1).timeout
	print("B")

func pisse():
	print("A")
	await get_tree().create_timer(1).timeout
	print("B")
	return 200
