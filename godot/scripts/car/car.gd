class_name Car
extends RigidBody3D

## Potencia del motor, que tan rapido va el auto
@export var _acceleration: float = 55.0
## Tope de velocidad lineal
@export var _max_speed: float = 20.0
## Que tanto gira horizontalmente, en grados
@export var _steering: float = 20.0
## Que tan rapido gira el auto
@export var _turn_speed: float = 4.0
## Debajo de esta velocidad el auto no gira
@export var _turn_stop_limit: float = 0.75
## Potencia de frenado, fuerza opuesta al movimiento
@export var _brake_force: float = 0.01
## Reduccion de la potencia del motor cuando se esta frenando
@export_range(0.1, 0.9, 0.01) var _engine_power_during_brake: float = 0.5

@onready var _pivot: CarPivot = $Pivot
@onready var _ground_ray_cast: RayCast3D = $Pivot/GroundRayCast
@onready var _impact_receiver: ImpactReceiver = $Pivot/ImpactReceiver

var _speed_input: float = 0
var _turn_input: float = 0
var _sphere_offset := Vector3.DOWN
var _is_braking := false
var _is_reversing := false
var _is_slipping := false


func _ready() -> void:
	_impact_receiver.impacted.connect(_apply_knockback)

func _process(_delta):
	if not _is_grounded():
		return
	
	_read_input()
	_rotate_car()

func _physics_process(_delta):
	_pivot.position = position + _sphere_offset
	_move_car()

func _is_grounded() -> bool:
	return _ground_ray_cast.is_colliding()

func _move_car() -> void:
	if not _is_grounded():
		return
	
	var final_movement_force: Vector3 = get_forward() * _acceleration * _speed_input
	
	if _is_braking:
		final_movement_force *= _engine_power_during_brake
		
		# Aplica friccion proporcional a la velocidad (mas rapido, mas friccion)
		if linear_velocity.length() > 0.1:
			var brake_strength: float = clamp(linear_velocity.length() * _brake_force, 0.0, 30.0)
			var brake_force: Vector3 = -linear_velocity.normalized() * brake_strength
			final_movement_force += brake_force
	
	apply_central_force(final_movement_force)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_limit_max_speed(state)

func _limit_max_speed(state: PhysicsDirectBodyState3D) -> void:
	if state.linear_velocity.length() > _max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * _max_speed

func _read_input() -> void:
	_read_movement_input()
	_read_steer_input()

func _read_movement_input() -> void:
	var is_accelerating: bool = Input.is_action_pressed("accelerate")
	_is_reversing = Input.is_action_pressed("reverse")
	_is_braking = Input.is_action_pressed("brake")
	
	if is_accelerating:
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

func _rotate_car() -> void:
	_pivot.rotate_front_wheels(_turn_input)
	
	if linear_velocity.length() > _turn_stop_limit:
		_pivot.rotate_car(_turn_input, _turn_speed, linear_velocity.length(), _ground_ray_cast.get_collision_normal())

func _apply_knockback(_source: Node3D, force: Vector3) -> void:
	apply_impulse(force)

func apply_slip(duration: float, friction_multiplier: float) -> void:
	if _is_slipping:
		return
	
	_is_slipping = true
	var previous_friction = physics_material_override.friction
	physics_material_override.friction *= friction_multiplier
	
	await get_tree().create_timer(duration).timeout
	physics_material_override.friction = previous_friction
	_is_slipping = false

func get_forward() -> Vector3:
	return _pivot.get_forward()

func get_pivot_transform() -> Transform3D:
	return _pivot.global_transform


#
