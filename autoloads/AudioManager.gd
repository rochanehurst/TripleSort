extends Node

var _sfx_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _sfx_volume: float = 1.0
var _music_volume: float = 0.7
var _sfx_library: Dictionary = {}

func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_music_player = AudioStreamPlayer.new()
	add_child(_sfx_player)
	add_child(_music_player)
	_music_player.volume_db = linear_to_db(_music_volume)

func register_sfx(key: String, stream: AudioStream) -> void:
	_sfx_library[key] = stream

func play_sfx(key: String) -> void:
	if _sfx_library.has(key):
		_sfx_player.stream = _sfx_library[key]
		_sfx_player.volume_db = linear_to_db(_sfx_volume)
		_sfx_player.play()

func play_music(stream: AudioStream, loop: bool = true) -> void:
	_music_player.stream = stream
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()

func set_sfx_volume(value: float) -> void:
	_sfx_volume = clamp(value, 0.0, 1.0)

func set_music_volume(value: float) -> void:
	_music_volume = clamp(value, 0.0, 1.0)
	_music_player.volume_db = linear_to_db(_music_volume)
