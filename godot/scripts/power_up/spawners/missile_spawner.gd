class_name MissileSpawner
extends PowerUpSpawner

const MISSILE_SCENE: PackedScene = preload("uid://bq46gsh8ddip6")
const SPAWN_OFFSET_DISTANCE := 3.0


func get_type() -> PowerUpManager.PowerUpType:
	return PowerUpManager.PowerUpType.MISSILE

func spawn(root_vehicle: Car, active_power_ups_container: Node3D) -> void:
	var missile_instance: MissilePowerUp = MISSILE_SCENE.instantiate()
	active_power_ups_container.add_child(missile_instance)
	
	var forward: Vector3 = root_vehicle.get_forward()
	var pivot_basis: Basis = root_vehicle.get_pivot_transform().basis
	var spawn_point: Vector3 = root_vehicle.global_position + forward * SPAWN_OFFSET_DISTANCE
	var missile_transform := Transform3D(pivot_basis, spawn_point)
	
	missile_instance.global_transform = missile_transform
	missile_instance.set_forward(forward)
