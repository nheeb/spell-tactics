class_name Keyword extends Resource

var internal_name: String
var logic: KeywordLogic

@export var pretty_name: String
@export var describtion: String

func on_load():
	if internal_name == "":
		internal_name = resource_path.split("/")[-1].split(".")[0]
		var directory = "/".join(resource_path.split("/").slice(0, -1))
		var logic_object = (load(directory + "/" + internal_name + ".gd") as Script).new()
		assert(logic_object is KeywordLogic)
		logic = logic_object
