class_name OilPuddleSpawner
extends PowerUpSpawner

const OIL_PUDDLE_SCENE: PackedScene = preload("uid://b70bn0vkqgxkv")


func get_type() -> PowerUpManager.PowerUpType:
	return PowerUpManager.PowerUpType.OIL_PUDDLE

func spawn(root_vehicle: Car, active_power_ups_container: Node3D) -> void:
	var terrain_collision: Dictionary = _get_terrain_collision_data(root_vehicle)
	
	if not terrain_collision.is_empty():
		_spawn_oil_puddle(
			root_vehicle.get_pivot_transform().basis,
			terrain_collision.position,
			active_power_ups_container
		)

func _get_terrain_collision_data(root_vehicle: Node3D) -> Dictionary:
	var raycast_from: Vector3 = root_vehicle.global_position + Vector3.UP
	var raycast_to: Vector3 = root_vehicle.global_position + Vector3.DOWN * 2
	var terrain_mask = 1 << 31  # mask = 1 << (layer_number - 1) => layer 32. TODO: no me gusta esto.
	
	var query := PhysicsRayQueryParameters3D.create(raycast_from, raycast_to, terrain_mask)
	return get_world_3d().direct_space_state.intersect_ray(query)

func _spawn_oil_puddle(oil_puddle_basis: Basis, collision_point: Vector3, container: Node3D) -> void:
	var oil_puddle_instance: OilPuddlePowerUp = OIL_PUDDLE_SCENE.instantiate()
	container.add_child(oil_puddle_instance)
	
	# Nota: esta no es la forma matematicamente correcta de hacerlo, pero es simple y anda
	var z_fighting_offset: Vector3 = oil_puddle_basis.y * 0.001
	var spawn_position = collision_point + z_fighting_offset
	oil_puddle_instance.global_transform = Transform3D(oil_puddle_basis, spawn_position)




#
