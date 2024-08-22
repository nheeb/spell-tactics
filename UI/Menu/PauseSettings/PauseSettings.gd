extends CanvasLayer


func _ready() -> void:
	# initialize possible render resolutions
	%RenderResOptions.clear()
	for res in Settings.RENDER_RESOLUTIONS:
		%RenderResOptions.add_item(str(res.x) + " × " + str(res.y))
	
	# TODO set index of active resolution, (initialize(settings) function?)
	#%RenderResOptions

func _on_resume_button_pressed() -> void:
	Game.unpause()


func _on_option_button_item_selected(index: int) -> void:
	Game.settings.render_resolution = index
	#Game.settings.apply_to_game()

