extends Node3D

@export var rotation_speed: float = 15.0  # grados por segundo

func _process(delta):
	rotate_y(deg_to_rad(rotation_speed * delta))
