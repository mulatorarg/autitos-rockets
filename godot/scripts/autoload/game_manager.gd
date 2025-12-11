extends Node
## Singleton para gestionar el estado global del juego

enum GameState {
	MENU,
	COUNTDOWN,
	RACING,
	PAUSED,
	FINISHED
}

var current_state: GameState = GameState.MENU

const MENU_SCENE_PATH := "res://scenes/ui/menu.tscn"
const SETTINGS_PATH_PRIORITY := [
	"res://config/settings.cfg",
	"user://settings.cfg"
]
const DEFAULT_SETTINGS := {
	"music_volume": 0.4,
	"sfx_volume": 0.7,
	"resolution": Vector2i(1920, 1080),
	"vsync_enabled": true
}
const SUPPORTED_RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440)
]

var _settings: Dictionary = DEFAULT_SETTINGS.duplicate(true)
var _settings_file_path: String = ""

signal state_changed(new_state: GameState)


func _ready() -> void:
	_settings_file_path = _find_existing_settings_file()
	if _settings_file_path.is_empty():
		_settings = DEFAULT_SETTINGS.duplicate(true)
		_settings_file_path = SETTINGS_PATH_PRIORITY[0]
		apply_settings()
	else:
		_load_settings_from_file(_settings_file_path)


func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	state_changed.emit(new_state)


func start_race() -> void:
	change_state(GameState.COUNTDOWN)


func begin_racing() -> void:
	change_state(GameState.RACING)


func pause_game() -> void:
	if current_state == GameState.RACING:
		change_state(GameState.PAUSED)
		var tree := get_tree()
		if tree:
			tree.paused = true


func resume_game() -> void:
	if current_state == GameState.PAUSED:
		change_state(GameState.RACING)
		var tree := get_tree()
		if tree:
			tree.paused = false


func finish_race() -> void:
	change_state(GameState.FINISHED)


func restart_race() -> void:
	RaceManager.reset_state()

	var tree := get_tree()
	if tree:
		tree.paused = false
		tree.reload_current_scene()
	else:
		push_warning("SceneTree no disponible al intentar reiniciar la carrera")


func go_to_menu() -> void:
	var tree := get_tree()
	if tree == null:
		push_warning("SceneTree no disponible al intentar ir al menú")
		return

	tree.paused = false
	RaceManager.reset_state()
	change_state(GameState.MENU)
	tree.change_scene_to_file(MENU_SCENE_PATH)


func get_settings() -> Dictionary:
	return _settings.duplicate(true)


func get_supported_resolutions() -> Array[Vector2i]:
	return SUPPORTED_RESOLUTIONS.duplicate() as Array[Vector2i]


func update_settings(new_settings: Dictionary) -> void:
	for key in new_settings.keys():
		if _settings.has(key):
			_settings[key] = new_settings[key]
	apply_settings()


func apply_settings() -> void:
	AudioManager.change_music_volume(_settings["music_volume"])
	AudioManager.change_sfx_volume(_settings["sfx_volume"])

	DisplayServer.window_set_size(_settings["resolution"])
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if _settings["vsync_enabled"] else DisplayServer.VSYNC_DISABLED
	)


func save_settings() -> void:
	for path in SETTINGS_PATH_PRIORITY:
		if _save_settings_to_path(path):
			_settings_file_path = path
			return
	push_warning("No se pudo guardar la configuración en ninguna ruta disponible")


func _save_settings_to_path(path: String) -> bool:
	var dir_path := path.get_base_dir()
	if not dir_path.is_empty():
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_path))

	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", _settings["music_volume"])
	config.set_value("audio", "sfx_volume", _settings["sfx_volume"])
	config.set_value("video", "resolution", _settings["resolution"])
	config.set_value("video", "vsync", _settings["vsync_enabled"])

	var err := config.save(path)
	return err == OK


func _load_settings_from_file(path: String) -> void:
	var config := ConfigFile.new()
	var err := config.load(path)
	if err != OK:
		push_warning("No se pudo cargar la configuración, usando valores por defecto")
		_settings = DEFAULT_SETTINGS.duplicate(true)
		apply_settings()
		return

	_settings["music_volume"] = float(config.get_value("audio", "music_volume", DEFAULT_SETTINGS["music_volume"]))
	_settings["sfx_volume"] = float(config.get_value("audio", "sfx_volume", DEFAULT_SETTINGS["sfx_volume"]))
	var saved_resolution = config.get_value("video", "resolution", DEFAULT_SETTINGS["resolution"])
	if saved_resolution is Vector2i:
		_settings["resolution"] = saved_resolution
	elif saved_resolution is Vector2:
		_settings["resolution"] = Vector2i(saved_resolution)
	else:
		_settings["resolution"] = DEFAULT_SETTINGS["resolution"]
	_settings["vsync_enabled"] = bool(config.get_value("video", "vsync", DEFAULT_SETTINGS["vsync_enabled"]))
	apply_settings()


func _find_existing_settings_file() -> String:
	for path in SETTINGS_PATH_PRIORITY:
		if FileAccess.file_exists(path):
			return path
	return ""
