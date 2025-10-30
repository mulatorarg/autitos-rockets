@abstract
class_name CarModel
extends Node3D

@export var _body_tilt: float = 35.0

var _front_wheels: Array[Node3D]
var _body_model: Node3D


@abstract
func _get_body_model() -> Node3D

@abstract
func _get_front_wheels() -> Array[Node3D]

func _ready():
	top_level = true
	_body_model = _get_body_model()
	_front_wheels = _get_front_wheels()

func rotate_front_wheels(angle: float) -> void:
	for wheel: Node3D in _front_wheels:
		wheel.rotation.y = angle

func rotate_model(angle: float, rotation_speed: float, linear_velocity_magnitude: float, collision_normal: Vector3) -> void:
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
	_body_model.rotation.z = lerp(_body_model.rotation.z, t, 5.0 * delta)

func _align_with_slopes(delta: float, collision_normal: Vector3) -> void:
	var xform: Transform3D = _get_y_alignment(global_transform, collision_normal)
	global_transform = global_transform.interpolate_with(xform, 10.0 * delta)

func _get_y_alignment(xform: Transform3D, new_y: Vector3) -> Transform3D:
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	return xform.orthonormalized()
