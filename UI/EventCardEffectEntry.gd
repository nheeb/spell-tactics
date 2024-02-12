extends PanelContainer

func setup(title: String, effect: String) -> void:
	%TitleLabel.text = title
	%EffectLabel.text = effect
	await get_tree().process_frame
	%EffectLabel.fix_me()
