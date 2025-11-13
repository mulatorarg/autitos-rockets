class_name CarPivot
extends Node3D

## Efecto visual al doblar. Con valores mas chicos el auto se tiltea mas
@export_range(5, 50, 1) var _body_tilt: float = 30.0

@onready var _car_model: CarModel = $CarModel as CarModel


func _ready() -> void:
	top_level = true

func get_forward() -> Vector3:
	return -global_transform.basis.z.normalized()

func rotate_front_wheels(angle: float) -> void:
	if _car_model != null:
		_car_model.rotate_front_wheels(angle)

func rotate_car(angle: float, rotation_speed: float, linear_velocity_magnitude: float, collision_normal: Vector3) -> void:
	var delta: float = get_physics_process_delta_time()
	
	_rotate_body(delta, angle, rotation_speed)
	_tilt_body(delta, angle, linear_velocity_magnitude)
	_align_with_slopes(delta, collision_normal)

func _rotate_body(delta: float, angle: float, rotation_speed: float) -> void:
	var new_basis: Basis = global_transform.basis.rotated(global_transform.basis.y, angle)
	global_transform.basis = global_transform.basis.slerp(new_basis, rotation_speed * delta)
	global_transform = global_transform.orthonormalized()

func _tilt_body(delta: float, angle: float, linear_velocity_magnitude: float) -> void:
	var t: float = -angle * linear_velocity_magnitude / _body_tilt
	rotation.z = lerp(rotation.z, t, 5.0 * delta)

func _align_with_slopes(delta: float, collision_normal: Vector3) -> void:
	var xform: Transform3D = _get_y_alignment(global_transform, collision_normal)
	global_transform = global_transform.interpolate_with(xform, 10.0 * delta)

func _get_y_alignment(xform: Transform3D, new_y: Vector3) -> Transform3D:
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	return xform.orthonormalized()
