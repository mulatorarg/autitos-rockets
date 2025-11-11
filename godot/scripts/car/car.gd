class_name Car
extends RigidBody3D

## Clase base para todos los autos (jugador y enemigos)

## Potencia del motor, que tan rapido va el auto
@export var _acceleration: float = 55.0
## Que tanto gira horizontalmente, en grados (usado por clases hijas)
@warning_ignore("unused_private_class_variable")
@export var _steering: float = 20.0
## Que tan rapido gira el auto
@export var _turn_speed: float = 4.0
## Debajo de esta velocidad el auto no gira
@export var _turn_stop_limit: float = 0.75
## Potencia de frenado, fuerza opuesta al movimiento
@export var _brake_force: float = 0.01
## Reduccion de la potencia del motor cuando se esta frenando
@export_range(0.1, 0.9, 0.01) var _engine_power_during_brake: float = 0.5

@onready var _car_model: CarModel = $CarModel
@onready var _ground_ray_cast: RayCast3D = $CarModel/GroundRayCast

var _speed_input: float = 0
var _turn_input: float = 0
var _sphere_offset := Vector3.DOWN
var _is_braking := false
## Si el auto está en reversa (usado por clases hijas para invertir controles)
@warning_ignore("unused_private_class_variable")
var _is_reversing := false


func _process(_delta):
	if not _is_grounded():
		return
	
	_read_input()
	_rotate_model()

func _physics_process(_delta):
	_car_model.position = position + _sphere_offset
	_move_car()

func _is_grounded() -> bool:
	return _ground_ray_cast.is_colliding()

func _move_car() -> void:
	# Bloquear movimiento cuando no se está corriendo (COUNTDOWN/PAUSED/FINISHED)
	if GameManager.current_state != GameManager.GameState.RACING:
		return

	if not _is_grounded():
		return

	var final_movement_force: Vector3 = -_car_model.global_transform.basis.z * _acceleration * _speed_input

	if _is_braking:
		final_movement_force *= _engine_power_during_brake

		# Aplica friccion proporcional a la velocidad (mas rapido, mas friccion)
		if linear_velocity.length() > 0.1:
			var brake_strength: float = clamp(linear_velocity.length() * _brake_force, 0.0, 30.0)
			var brake_force: Vector3 = -linear_velocity.normalized() * brake_strength
			final_movement_force += brake_force

	apply_central_force(final_movement_force)

## Lee el input y actualiza _speed_input, _turn_input, _is_braking. 
## Los hijos deben implementar esto.
func _read_input() -> void:
	_read_movement_input()
	_read_steer_input()

## Método virtual: Implementar en clases hijas para definir el input de movimiento
func _read_movement_input() -> void:
	pass

## Método virtual: Implementar en clases hijas para definir el input de dirección
func _read_steer_input() -> void:
	pass

func _rotate_model() -> void:
	_car_model.rotate_front_wheels(_turn_input)
	
	if linear_velocity.length() > _turn_stop_limit:
		_car_model.rotate_model(_turn_input, _turn_speed, linear_velocity.length(), _ground_ray_cast.get_collision_normal())

## Velocidad lineal actual en m/s.
## Se expone para HUD/Debug y cálculos de posiciones.
func get_speed() -> float:
	return linear_velocity.length()

## Vector forward del auto consistente con el modelo visual.
## Utilizado para cálculos de IA, ángulos y raycasts hacia adelante.
func get_forward() -> Vector3:
	return (-_car_model.global_transform.basis.z).normalized()
