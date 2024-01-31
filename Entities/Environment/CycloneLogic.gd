extends EntityLogic

var duration_left = 3

@export var damage := 2

func on_create():
	print("hmmm'ello")
	combat.round_ended.connect(next_round) # in end phase

func on_delete():
	if combat.round_ended.is_connected(next_round):
		combat.round_ended.disconnect(next_round)


func next_round(current_round: int):
	if duration_left <= 0:
		# delete entity
		pass
	# get enemies / player standing on cyclone tile.
	if entity.current_tile == null:
		printerr("cyclone without a tile? %d" % current_round)
	var tile: Tile = entity.current_tile
	var enemies = tile.get_enemies()
	for enemy in enemies:
		enemy.inflict_damage(damage)
	if combat.player.current_tile == tile:
		combat.player.inflict_damage(damage)
	
	duration_left -= 1
	if duration_left <= 0:
		# delete entity
		pass
