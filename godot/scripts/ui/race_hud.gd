extends CanvasLayer
class_name RaceHUD
## HUD para mostrar información de la carrera

@export var total_laps: int = 3

@onready var speed_label: Label = $TopBar/HBoxContainer/SpeedCard/CardContent/SpeedTexts/SpeedLabel
@onready var position_label: Label = $TopBar/HBoxContainer/PositionCard/CardContent/PositionTexts/PositionLabel
@onready var lap_label: Label = $TopBar/HBoxContainer/LapCard/CardContent/LapTexts/LapLabel
@onready var time_label: Label = $TopBar/HBoxContainer/TimeCard/CardContent/TimeTexts/TimeLabel
@onready var countdown_label: Label = $CenterContainer/CountdownLabel
@onready var finish_panel: Panel = $FinishPanel
@onready var finish_time_label: Label = $FinishPanel/VBoxContainer/FinishTimeLabel
@onready var finish_position_label: Label = $FinishPanel/VBoxContainer/HBoxContainer/FinishPositionLabel
@onready var pause_overlay: Control = $PauseOverlay
@onready var resume_button: Button = $PauseOverlay/PausePanel/VBoxContainer/ResumeButton
@onready var restart_button: Button = $PauseOverlay/PausePanel/VBoxContainer/RestartButton
@onready var menu_button: Button = $PauseOverlay/PausePanel/VBoxContainer/MenuButton

var _previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.state_changed.connect(_on_game_state_changed)
	RaceManager.race_completed.connect(_on_race_completed)
	RaceManager.total_laps = total_laps
	resume_button.pressed.connect(_on_resume_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	finish_panel.hide()
	countdown_label.hide()
	_set_pause_menu_visible(false)


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
	speed_label.text = "%d km/h" % int(speed_kmh)
	
	# Posición
	position_label.text = "%dº" % stats.position
	
	# Vuelta
	lap_label.text = "%d / %d" % [stats.laps + 1, RaceManager.total_laps]
	
	# Tiempo
	var time_seconds = stats.time
	var minutes = int(time_seconds / 60)
	var seconds = int(time_seconds) % 60
	var milliseconds = int((time_seconds - int(time_seconds)) * 1000)
	time_label.text = "%02d:%02d.%03d" % [minutes, seconds, milliseconds]


func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.COUNTDOWN:
			_start_countdown()
			_set_pause_menu_visible(false)
		GameManager.GameState.RACING:
			countdown_label.hide()
			_set_pause_menu_visible(false)
		GameManager.GameState.FINISHED:
			_set_pause_menu_visible(false)
		GameManager.GameState.PAUSED:
			_set_pause_menu_visible(true)
		GameManager.GameState.MENU:
			_set_pause_menu_visible(false)


func _start_countdown() -> void:
	countdown_label.show()
	countdown_label.modulate = Color.WHITE
	
	# Cuenta regresiva: 3, 2, 1, VAMOOOS!
	countdown_label.text = "3"
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = "1"
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = "VAMOOOS!"
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
		4:
			message = "Cuarto Lugar!"
		_:
			message = "¡Carrera Completada!"
	
	finish_position_label.text = message + "\n" + finish_position_label.text


func _set_pause_menu_visible(value: bool) -> void:
	pause_overlay.visible = value
	pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE
	if value:
		_previous_mouse_mode = Input.get_mouse_mode()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		resume_button.grab_focus()
	else:
		Input.set_mouse_mode(_previous_mouse_mode)


func _on_resume_button_pressed() -> void:
	GameManager.resume_game()


func _on_restart_button_pressed() -> void:
	GameManager.restart_race()


func _on_menu_button_pressed() -> void:
	GameManager.go_to_menu()
