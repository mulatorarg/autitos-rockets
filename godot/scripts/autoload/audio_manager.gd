extends Node
# AudioManager

var _music_player := AudioStreamPlayer.new()
var _sfx_pool := Node3D.new()

const MUSIC_BUS_NAME := "Music"
const SFX_BUS_NAME := "SFX"
const MAX_VOLUME := 1.0
const START_MUSIC_VOLUME := 0.1
const START_SFX_VOLUME := 0.3


func _ready():
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player.bus = MUSIC_BUS_NAME
	_music_player.finished.connect(_music_player.play) # Loop
	
	add_child(_music_player)
	add_child(_sfx_pool)
	
	#change_music_volume(START_MUSIC_VOLUME)
	#change_sfx_volume(START_SFX_VOLUME)

func play_music(stream: AudioStream) -> void:
	if stream == _music_player.stream:
		return
	
	_music_player.stream = stream
	_music_player.play()

func play_sfx(stream: AudioStream, position: Vector3, volume: float = MAX_VOLUME) -> void:
	var sfx_player: AudioStreamPlayer3D = _get_sfx_player_from_pool()
	
	sfx_player.global_position = position
	sfx_player.stream = stream
	sfx_player.volume_db = linear_to_db(volume)
	sfx_player.play()

func _get_sfx_player_from_pool() -> AudioStreamPlayer3D:
	for player: AudioStreamPlayer3D in _sfx_pool.get_children():
		if !player.playing:
			return player
	
	return _create_sfx_player()
	
func _create_sfx_player() -> AudioStreamPlayer3D:
	var sfx_player := AudioStreamPlayer3D.new()
	
	sfx_player.bus = SFX_BUS_NAME
	_sfx_pool.add_child(sfx_player)
	
	return sfx_player

func get_music_volume() -> float:
	return _get_bus_linear_volume(MUSIC_BUS_NAME)

func get_sfx_volume() -> float:
	return _get_bus_linear_volume(SFX_BUS_NAME)

func _get_bus_linear_volume(bus_name: String) -> float:
	return AudioServer.get_bus_volume_linear(_get_bus_index(bus_name))

func change_music_volume(linear_value: float) -> void:
	_change_bus_volume(MUSIC_BUS_NAME, linear_value)

func change_sfx_volume(linear_value: float) -> void:
	_change_bus_volume(SFX_BUS_NAME, linear_value)

func _change_bus_volume(bus_name: String, volume_linear: float) -> void:
	AudioServer.set_bus_volume_linear(_get_bus_index(bus_name), volume_linear)

func _get_bus_index(bus_name: String) -> int:
	return AudioServer.get_bus_index(bus_name)




#
