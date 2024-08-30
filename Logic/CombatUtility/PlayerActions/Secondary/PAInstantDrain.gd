class_name PAInstantDrain extends PlayerAction

var target_tile: Tile
var drain_active: Active

func _init(_target_tile: Tile) -> void:
	target_tile = _target_tile
	action_string = "Instant Drain on tile <%s>" % target_tile

func is_valid(combat: Combat) -> bool:
	if combat.input.current_castable:
		return false
	# Get the drain active from combat
	drain_active = Utility.array_safe_get(
		combat.actives.filter(
			func (a: Active): return a.type.internal_name == "Drain"
		), 0)
	if drain_active == null:
		push_error("No Drain Active found for PAInstantDrain")
	drain_active.update_possible_targets()
	return drain_active.is_selectable() and drain_active.is_target_possible(target_tile)

func abort(tile = null):
	signal_disposer.dispose()
	progress_tween.kill()
	target_tile.highlight.set_drain_progress(0.0)

var signal_disposer: SxCompositeDisposable
var progress_tween: Tween
func execute(combat: Combat) -> void:
	signal_disposer = SxCompositeDisposable.new()
	Sx.merge([
		Sx.from(Events.tile_click_released),
		Sx.from(Events.tile_hovered).filter(
			func (tile: Tile): return tile != target_tile
		)
	]).subscribe(abort).dispose_with(signal_disposer)
	progress_tween = VisualTime.new_tween().set_parallel(false)
	progress_tween.tween_method(target_tile.highlight.set_drain_progress, 0.0, 1.0, 0.8)
	Sx.from(progress_tween.finished)\
		.subscribe(quick_drain.bind(combat))\
		.dispose_with(signal_disposer)

func quick_drain(combat: Combat):
	signal_disposer.dispose()
	target_tile.highlight.set_drain_progress(0.0)
	var targets : Array[Tile] = [target_tile]
	combat.action_stack.process_player_action(PAQuickCast.new(drain_active, targets))

func on_fail(combat: Combat) -> void:
	pass
