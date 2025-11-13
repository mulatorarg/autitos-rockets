@abstract
class_name CarModel
extends Node3D

var _front_wheels: Array[Node3D]


@abstract
func _get_front_wheels() -> Array[Node3D]

func _ready():
	_front_wheels = _get_front_wheels()

func rotate_front_wheels(angle: float) -> void:
	for wheel: Node3D in _front_wheels:
		wheel.rotation.y = angle
