class_name EntityStatusType extends Resource

var internal_name: String
@export var pretty_name: String
@export var icon: Texture
@export var color: Color = Color.WHITE

@export var default_data := {}

## Logic script
var logic_script: GDScript

func _on_load() -> void:
	if internal_name == "":
		internal_name = resource_path.split("/")[-1].split(".")[0]
		var directory = "/".join(resource_path.split("/").slice(0, -1))
		logic_script = load(directory + "/" + internal_name + ".gd")
