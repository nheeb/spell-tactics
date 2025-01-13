class_name PAInstantDrain extends PlayerAction

var target_tile: Tile
var drain_active: Active
var interact_active: Active
var possible_drain := false
var possible_interact := false

func _init(_target_tile: Tile) -> void:
	target_tile = _target_tile
	action_string = "Instant Drain on tile <%s>" % target_tile
	blocking_types = [InputUtility.InputBlockType.Any]

func is_valid(combat: Combat) -> bool:
	if combat.input.current_castable:
		return false
	# Test if the tile is valid for the drain active
	drain_active = combat.castables.get_active_from_name("drain")
	drain_active.create_details(combat.player)
	possible_drain = drain_active.is_selectable() and drain_active.is_target_valid(target_tile)
	drain_active.reset_details()
	# Test if the tile is valid for the interact active
	interact_active = combat.castables.get_active_from_name("interact")
	interact_active.create_details(combat.player)
	possible_interact = interact_active.is_selectable() and interact_active.is_target_valid(target_tile)
	interact_active.reset_details()
	return possible_drain or possible_interact

func abort(tile = null):
	signal_disposer.dispose()
	progress_tween.kill()
	target_tile.highlight.set_border_progress(0.0)

var signal_disposer: SxCompositeDisposable
var progress_tween: Tween
func execute(combat: Combat) -> void:
	signal_disposer = SxCompositeDisposable.new()
	Sx.merge([
		Sx.from(Events.tile_click_released),
		Sx.from(PATileHoverUpdate.on_tile_hovered).filter(
			func (tile: Tile): return tile != target_tile
		)
	]).subscribe(abort).dispose_with(signal_disposer)
	# Make different colored border progress based on drain or interact
	if possible_interact:
		target_tile.highlight.set_border_progress_color(Color.ORANGE)
		target_tile.highlight.set_border_progress_width(.12)
	else:
		target_tile.highlight.set_border_progress_color(Color.CADET_BLUE)
		target_tile.highlight.set_border_progress_width(.08)
	var progress_time := .6 if possible_interact else .9
	progress_tween = VisualTime.new_tween().set_parallel(false)
	progress_tween.tween_method(target_tile.highlight.set_border_progress, 0.0, 1.0, progress_time)
	Sx.from(progress_tween.finished)\
		.subscribe(quick_drain.bind(combat))\
		.dispose_with(signal_disposer)

# TODO rename this better to sound like interact is also wanted

func quick_drain(combat: Combat):
	signal_disposer.dispose()
	target_tile.highlight.set_border_progress(0.0)
	var targets : Array[Tile] = [target_tile]
	var castable: Castable = interact_active if possible_interact else \
							(drain_active if possible_drain else null)
	if castable:
		combat.action_stack.process_player_action(PAQuickCast.new(castable, targets))

func on_fail(combat: Combat) -> void:
	pass
