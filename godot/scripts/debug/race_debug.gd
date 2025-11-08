extends Node

## Script de utilidad para debugging del sistema de carreras
## Agregar como hijo de la escena principal para ver información de debug

@onready var debug_label: Label = Label.new()
var show_debug: bool = true


func _ready() -> void:
	# Crear label de debug
	debug_label.position = Vector2(10, 100)
	debug_label.add_theme_font_size_override("font_size", 14)
	debug_label.add_theme_color_override("font_color", Color.YELLOW)
	debug_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	debug_label.add_theme_constant_override("shadow_offset_x", 1)
	debug_label.add_theme_constant_override("shadow_offset_y", 1)
	
	# Añadir al árbol de escena
	var canvas = CanvasLayer.new()
	canvas.layer = 100  # Asegurar que esté encima de todo
	add_child(canvas)
	canvas.add_child(debug_label)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_focus_next"):  # Tab key
		show_debug = !show_debug
		debug_label.visible = show_debug
	
	if show_debug:
		_update_debug_info()


func _update_debug_info() -> void:
	var debug_text = "=== DEBUG INFO (Tab para ocultar) ===\n\n"
	
	# Estado del juego
	debug_text += "Game State: %s\n" % GameManager.GameState.keys()[GameManager.current_state]
	
	# Info de la carrera
	debug_text += "Total Laps: %d\n" % RaceManager.total_laps
	debug_text += "Checkpoints: %d\n" % RaceManager.checkpoints.size()
	debug_text += "Registered Cars: %d\n\n" % RaceManager.car_data.size()
	
	# Info del jugador
	if RaceManager.player_car != null:
		var stats = RaceManager.get_player_stats()
		debug_text += "--- PLAYER ---\n"
		debug_text += "Position: %d\n" % stats.position
		debug_text += "Lap: %d/%d\n" % [stats.laps + 1, RaceManager.total_laps]
		debug_text += "Checkpoint: %d/%d\n" % [stats.checkpoint, RaceManager.checkpoints.size()]
		debug_text += "Speed: %.1f m/s\n" % stats.speed
		debug_text += "Finished: %s\n\n" % ("Yes" if stats.finished else "No")
	
	# Info de posiciones
	debug_text += "--- POSITIONS ---\n"
	for i in range(min(5, RaceManager.race_positions.size())):
		var pos_data = RaceManager.race_positions[i]
		var car_name = pos_data.car.name
		debug_text += "%d. %s (Lap %d, CP %d)\n" % [i + 1, car_name, pos_data.laps + 1, pos_data.checkpoint]
	
	debug_label.text = debug_text
