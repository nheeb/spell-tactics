class_name EnemyAction extends Resource

var internal_name: String = ""
@export var pretty_name: String
@export var icon: Texture
@export var color: Color = Color.WHITE

enum TargetType {None, Foes, Allies, Tiles, Entities}
@export var target_type : TargetType = TargetType.None
@export_range(1,8) var target_consider_count := 2
enum TargetConsiderMethod {Best, WeightSquaredRandom}
@export var target_consider_method : TargetConsiderMethod = TargetConsiderMethod.Best
@export var cooldown := 0
@export var alternative_action : EnemyAction = null

## Logic script
var logic_script: Script

static func load_from_file(path: String) -> CastableType:
	var res = load(path)
	if res == null:
		push_error("Castable could not be loaded. Path is %s" % path)
	res._on_load()
	return res

func _on_load() -> void:
	if internal_name == "":
		internal_name = resource_path.split("/")[-1].split(".")[0]
		var directory = "/".join(resource_path.split("/").slice(0, -1))
		logic_script = load(directory + "/" + internal_name + ".gd")
