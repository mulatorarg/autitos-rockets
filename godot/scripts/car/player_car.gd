class_name PlayerCar
extends Car

## Auto controlado por el jugador mediante teclado/gamepad

func _ready() -> void:
	super._ready()
	# Registrar este auto como el del jugador en el RaceManager
	RaceManager.register_car(self, true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("activate_power_up"):
		_power_up_manager.try_to_activate()
	
	if event.is_action_pressed("swap_power_up"):
		_power_up_manager.swap_power_up()

func _read_movement_input() -> void:
	var accel: bool = Input.is_action_pressed("accelerate")
	_is_reversing = Input.is_action_pressed("reverse")
	_is_braking = Input.is_action_pressed("brake")
	
	if accel:
		_speed_input = 1.0
	elif _is_reversing:
		_speed_input = -1.0
	else:
		_speed_input = 0.0


func _read_steer_input() -> void:
	var steer_dir: float = Input.get_axis("steer_right", "steer_left") * deg_to_rad(_steering)
	
	if _is_reversing:
		steer_dir = -steer_dir
	
	_turn_input = steer_dir
