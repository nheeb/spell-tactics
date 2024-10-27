class_name OverworldState extends Resource

@export var random_seed: int = 0
@export var map: OverworldMap
@export var stage: int = 0
@export var player_position: Vector2i = Vector2i(0, 0)
@export var adventure_state: AdventureState
@export var combat_state: CombatState = null
@export var meta: SaveFileMeta = null

func generate_meta(save_name: String = "Unnamed Savefile", screenshot : ImageTexture = null) -> void:
	meta = SaveFileMeta.new()
	meta.title = save_name
	meta.timestamp = Time.get_datetime_string_from_system()
	meta.stats = "%s HP | %s Coins | %s Cards" % \
			[adventure_state.health, adventure_state.coins, adventure_state.deck_states.size()]
	if screenshot:
		meta.screenshot = screenshot
	else:
		meta.screenshot = Utility.take_screenshot(3)
	meta.filename = "Savefile-" + meta.timestamp.replace(":", "-").replace("T", "-")\
			 + "-" + meta.title.replace(" ", "")
