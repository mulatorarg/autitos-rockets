extends Node3D


@onready var _options_menu: ScreenMenu = $CanvasLayer/OptionsMenu

const GAMEPLAY_MUSIC_1: AudioStream = preload("uid://dd7ifdfr2xsyp")


func _ready() -> void:
	AudioManager.play_music(GAMEPLAY_MUSIC_1)


func _on_btn_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tracks/office_exterior.tscn")


func _on_btn_opciones_pressed() -> void:
	_options_menu.open()


func _on_btn_salir_pressed() -> void:
	get_tree().quit()
