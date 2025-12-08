extends Node3D


func _on_btn_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tracks/office_interior.tscn")


func _on_btn_opciones_pressed() -> void:
	pass # Replace with function body.


func _on_btn_salir_pressed() -> void:
	get_tree().quit()
