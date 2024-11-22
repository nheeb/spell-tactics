extends PanelContainer

const PANEL_DEFAULT = preload("res://UI/Theme/EventCardPanelEntryDefault.tres")
const PANEL_HIGHLIGHT = preload("res://UI/Theme/EventCardPanelEntryHighlight.tres")

func setup(title: String, effect: String) -> void:
	%TitleLabel.text = title
	%EffectLabel.text = effect
	await VisualTime.visual_process
	%EffectLabel.fix_me()

func set_highlight(h: bool) -> void:
	%TitlePanel.set("theme_override_styles/panel", PANEL_HIGHLIGHT if h else PANEL_DEFAULT)
	%EffectLabel.label_settings.font_color = Color.BLACK if h else Color.WEB_GRAY
