class_name SUVCarModel
extends CarModel


func _get_front_wheels() -> Array[Node3D]:
	return [$suv2/wheel_frontLeft, $suv2/wheel_frontRight]
