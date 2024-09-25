class_name EntityStatusType extends Resource

var internal_name: String
@export var pretty_name: String
@export var icon: Texture
@export var color: Color = Color.WHITE
@export_multiline var text: String = ""

@export var default_data := {}

@export_group("Lifetime")
## This will add the value '_lifetime' to the data.
## Lifetime decreases by 1 each End Phase. 
## When it reaches 0 the status will be removed.
@export var has_lifetime := false
@export var lifetime_default := 1
## What happens with lifetime when the status is extended [br]
## [b] max [/b] Take the bigger lifetime [br]
## [b] sum [/b] Add the new lifetime [br]
## [b] reset [/b] Take the new lifetime [br]
## [b] ignore [/b] Take the old lifetime
@export_enum(
	"max:0", "sum:1", "reset:2", "ignore:3"
	) var lifetime_extend_method: int = 0

@export_group("Visuals")
@export var make_floating_icon: bool = true

@export_group("Extras")

@export var enemy_actions: Array[EnemyActionArgs]

## Logic script
var logic_script: GDScript

func _on_load() -> void:
	if internal_name == "":
		internal_name = resource_path.split("/")[-1].split(".")[0]
		var directory = "/".join(resource_path.split("/").slice(0, -1))
		logic_script = load(directory + "/" + internal_name + ".gd")

func create_logic() -> EntityStatusLogic:
	_on_load()
	if logic_script:
		return logic_script.new()
	return EntityStatusLogic.new()
