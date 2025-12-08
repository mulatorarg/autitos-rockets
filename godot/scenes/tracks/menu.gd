extends Node3D


@onready var _options_menu: ScreenMenu = $CanvasLayer/OptionsMenu


func _on_btn_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tracks/office_interior.tscn")


func _on_btn_opciones_pressed() -> void:
	_options_menu.open()


func _on_btn_salir_pressed() -> void:
	get_tree().quit()
