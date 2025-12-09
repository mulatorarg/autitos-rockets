extends Node3D


@onready var _options_menu: ScreenMenu = $CanvasLayer/OptionsMenu
@onready var _level_select_menu: LevelSelectMenu = $CanvasLayer/LevelSelectMenu

const GAMEPLAY_MUSIC_1: AudioStream = preload("uid://dd7ifdfr2xsyp")


func _ready() -> void:
	AudioManager.play_music(GAMEPLAY_MUSIC_1)
	_level_select_menu.level_chosen.connect(_on_level_selected)


func _on_btn_jugar_pressed() -> void:
	_level_select_menu.open()


func _on_btn_opciones_pressed() -> void:
	_options_menu.open()


func _on_btn_salir_pressed() -> void:
	get_tree().quit()


func _on_level_selected(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
