class_name AudioManager extends Node

var registered_3d_players: Array[AudioStreamPlayer3D]
var free_stream_players: Array[AudioStreamPlayer]
var running_stream_players: Array[AudioStreamPlayer]

var sounds: Dictionary

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
		
	# Init all the local sounds
	for sound in self.get_children():
		if sound is CustomAudio:
			sounds[sound.name] = sound


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func register_3d(node: AudioStreamPlayer3D) -> int:
	var id = len(registered_3d_players)
	registered_3d_players.append(node)
	
	return id
	
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
			player.play()
		else:
			push_warning(title + " could not be played. There are no free audio players.")
	else:
		push_warning(title + " could not be played. The corresponding sound could not be found.")
		
	
