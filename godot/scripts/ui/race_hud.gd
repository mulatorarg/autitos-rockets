extends CanvasLayer

## HUD para mostrar información de la carrera

@onready var speed_label: Label = $MarginContainer/VBoxContainer/SpeedLabel
@onready var position_label: Label = $MarginContainer/VBoxContainer/PositionLabel
@onready var lap_label: Label = $MarginContainer/VBoxContainer/LapLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel
@onready var countdown_label: Label = $CenterContainer/CountdownLabel
@onready var finish_panel: Panel = $FinishPanel
@onready var finish_time_label: Label = $FinishPanel/VBoxContainer/FinishTimeLabel
@onready var finish_position_label: Label = $FinishPanel/VBoxContainer/FinishPositionLabel


func _ready() -> void:
	GameManager.state_changed.connect(_on_game_state_changed)
	RaceManager.race_completed.connect(_on_race_completed)
	finish_panel.hide()
	countdown_label.hide()


func _process(_delta: float) -> void:
	if GameManager.current_state == GameManager.GameState.RACING:
		_update_hud()


func _update_hud() -> void:
	var stats = RaceManager.get_player_stats()
	
	# Verificar que tenemos datos válidos
	if not stats.has("time"):
		return
	
	# Velocidad en km/h (conversión aproximada)
	var speed_kmh = stats.speed * 3.6  # m/s a km/h aproximado
	speed_label.text = "Velocidad: %d km/h" % int(speed_kmh)
	
	# Posición
	position_label.text = "Posición: %d" % stats.position
	
	# Vuelta
	lap_label.text = "Vuelta: %d / %d" % [stats.laps + 1, RaceManager.total_laps]
	
	# Tiempo
	var time_seconds = stats.time
	var minutes = int(time_seconds / 60)
	var seconds = int(time_seconds) % 60
	var milliseconds = int((time_seconds - int(time_seconds)) * 1000)
	time_label.text = "Tiempo: %02d:%02d.%03d" % [minutes, seconds, milliseconds]


func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.COUNTDOWN:
			_start_countdown()
		GameManager.GameState.RACING:
			countdown_label.hide()
		GameManager.GameState.FINISHED:
			pass  # El panel de finalización se muestra en _on_race_completed


func _start_countdown() -> void:
	countdown_label.show()
	countdown_label.modulate = Color.WHITE
	
	# Cuenta regresiva: 3, 2, 1, GO!
	countdown_label.text = "3"
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = "1"
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = "GO!"
	countdown_label.modulate = Color.GREEN
	
	GameManager.begin_racing()
	
	await get_tree().create_timer(0.5).timeout
	countdown_label.hide()


func _on_race_completed(car: Car, final_time: float) -> void:
	if car == RaceManager.player_car:
		_show_finish_screen(final_time)


func _show_finish_screen(final_time: float) -> void:
	finish_panel.show()
	
	var position = RaceManager.get_car_position(RaceManager.player_car)
	
	# Formatear tiempo
	var minutes = int(final_time / 60)
	var seconds = int(final_time) % 60
	var milliseconds = int((final_time - int(final_time)) * 1000)
	
	finish_time_label.text = "Tiempo: %02d:%02d.%03d" % [minutes, seconds, milliseconds]
	finish_position_label.text = "Posición Final: %d" % position
	
	# Mensaje según la posición
	var message = ""
	match position:
		1:
			message = "¡VICTORIA!"
		2:
			message = "¡Segundo Lugar!"
		3:
			message = "¡Tercer Lugar!"
		_:
			message = "¡Carrera Completada!"
	
	finish_position_label.text = message + "\n" + finish_position_label.text
