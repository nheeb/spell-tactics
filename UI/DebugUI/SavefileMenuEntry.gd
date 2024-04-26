class_name SavefileMenuEntry extends PanelContainer

var overworld_state: OverworldState

func set_overworld_state(ows: OverworldState) -> void:
	overworld_state = ows
	if not overworld_state.meta:
		overworld_state.generate_meta("Unnamed Savefile")
	setup_with_meta(overworld_state.meta)

func setup_with_meta(meta: SaveFileMeta) -> void:
	%LabelTitle.text = meta.title
	%LabelStats.text = meta.stats
	%LabelTimestamp.text = meta.timestamp
	%Screenshot.texture = meta.screenshot

signal select(entry: SavefileMenuEntry)

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action("select"):
		select.emit(self)

const PANEL_DEFAULT = preload("res://UI/Theme/EventCardPanelEntryDefault.tres")
const PANEL_HIGHLIGHT = preload("res://UI/Theme/EventCardPanelEntryHighlight.tres")
func set_highlight(h: bool) -> void:
	set("theme_override_styles/panel", PANEL_HIGHLIGHT if h else PANEL_DEFAULT)
