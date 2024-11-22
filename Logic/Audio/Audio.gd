class_name AudioManager extends Node

var registered_3d_players: Dictionary
var free_stream_players: Array[AudioStreamPlayer]
var running_stream_players: Array[AudioStreamPlayer]

var free_music_players: Array[AudioStreamPlayer]
var running_music_players: Dictionary

var sounds: Dictionary

var id_3d := 0

@export var max_voices := 64
@export var max_music_voices := 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player_node = Node.new()
	add_child(player_node)
	# Init all the players
	for i in range(max_voices):
		var player = AudioStreamPlayer.new()
		free_stream_players.append(player)
		player_node.add_child(player)
		
	for i in range(max_music_voices):
		var player = AudioStreamPlayer.new()
		free_music_players.append(player)
		player_node.add_child(player)
		
	# Init all the local sounds
	for sound in self.get_children():
		if sound is CustomAudio:
			sounds[sound.name] = sound


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

######### 3D ########

# Register a 3d player to possible access it from different places
func register_3d(node: AudioStreamPlayer3D) -> int:
	var id = id_3d
	registered_3d_players[id] = node
	
	id_3d += 1
	
	return id
	
# Deregister a 3d player
func deregister_3d(id: int) -> void:
	if id in registered_3d_players.keys():
		registered_3d_players.erase(id)
		
# Access a 3d player using its ID
func access_3d(id: int) -> AudioStreamPlayer3D:
	if id not in registered_3d_players.keys():
		push_warning("There is no registered player with that id.")
		return null
	return registered_3d_players[id]
	
############ 2D ################

# Play a sound effect with the given title. It has to match the name of the CustomAudio node
# volume_adjust: adjust the volume in dB on a per sound basis
# offset: Add an offset before the sound. This also react to the time speed changes
# scale_time: Apply the time scaling effect to the sound
func play(title: String, volume_adjust: float = 0., offset: float = 0., scale_time: bool = true) -> void:
	if offset > 0.001:
		push_warning("Audio offset is not implemented yet!")
		
	if title in sounds.keys():
		var sound = sounds[title]
		
		# Grab a free player
		var player: AudioStreamPlayer = free_stream_players.pop_back()
		if player:
			player.set_stream(sound.stream)
			var volume = volume_adjust + sound.base_volume_db
			player.set_volume_db(volume)
			if scale_time:
				player.set_pitch_scale(VisualTime.visual_time_scale)
				player.set_bus("TimeCorrection")
			else:
				player.set_bus("Master")
			player.play()
			running_stream_players.append(player)
		else:
			push_warning(title + " could not be played. There are no free audio players.")
	else:
		push_warning(title + " could not be played. The corresponding sound could not be found.")

################ Music ####################

# Start the song with the given string. The imported audio file will have to be set to loop.
# This will stop any other running music players
func start_music(title: String, volume_adjust: float = 0.) -> void:
	stop_all_music()
	add_music(title, volume_adjust)
	
# Add another layer of music
func add_music(title: String, volume_adjust: float = 0.) -> void:
	if title in sounds.keys():
		var sound = sounds[title]
		
		var player: AudioStreamPlayer = free_music_players.pop_back()
		
		if player:
			player.set_stream(sound.stream)
			var volume = volume_adjust + sound.base_volume_db
			player.set_volume_db(volume)
			
			player.play()
			running_music_players[title] = player
		else:
			push_warning(title + " could not be played. There are no free music players.")
	else:
		push_warning(title + " could not be played. The corresponding sound could not be found.")
		
# Stop the song with the given title
func stop_music(title: String) -> void:
	if title in running_music_players.keys():
		var player: AudioStreamPlayer = running_music_players[title]
		player.stop()
		free_music_players.append(player)
		running_music_players.erase(title)
		
# Stop all the runnig music players
func stop_all_music() -> void:
	for player_key in running_music_players.keys():
		var player: AudioStreamPlayer = running_music_players[player_key]
		player.stop()
		free_music_players.append(player)
		running_music_players.erase(player_key)
	
# Fade from all running songs into the song with the title
func fade_music(title: String, speed: int = 1) -> void:
	pass

# Runs once per seconmd to check for finished sounds
func _on_cleanup_timer_timeout() -> void:
	var remove_players: Array[AudioStreamPlayer]
	for player in running_stream_players:
		if not player.playing:
			free_stream_players.append(player)
			remove_players.append(player)
			
	for player in remove_players:
		running_stream_players.erase(player)
