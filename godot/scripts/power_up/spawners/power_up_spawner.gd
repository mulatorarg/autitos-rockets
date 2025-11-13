@abstract
class_name PowerUpSpawner
extends Node3D


@abstract
func get_type() -> PowerUpManager.PowerUpType

@abstract
func spawn(root_vehicle: Car, active_power_ups_container: Node3D) -> void
