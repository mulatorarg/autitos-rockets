class_name OilPuddleSpawner
extends PowerUpSpawner

const OIL_PUDDLE_SCENE: PackedScene = preload("uid://b70bn0vkqgxkv")
const SPAWN_OFFSET_DISTANCE := 15.0
const OIL_PUDDLE_DROP_SFX: AudioStream = preload("uid://cr2npcw7tdeea")


func get_type() -> PowerUpManager.PowerUpType:
	return PowerUpManager.PowerUpType.OIL_PUDDLE

func spawn(root_vehicle: Car, active_power_ups_container: Node3D) -> void:
	var floor_collision: Dictionary = _get_floor_collision_data(root_vehicle)
	
	if not floor_collision.is_empty():
		AudioManager.play_sfx(OIL_PUDDLE_DROP_SFX, global_position)
		
		_spawn_oil_puddle(
			root_vehicle.get_pivot_transform().basis,
			floor_collision.position,
			active_power_ups_container
		)

func _get_floor_collision_data(root_vehicle: Car) -> Dictionary:
	var car_backwards: Vector3 = root_vehicle.get_forward() * -1
	var raycast_from: Vector3 = root_vehicle.global_position + Vector3.UP + car_backwards * SPAWN_OFFSET_DISTANCE
	var raycast_to: Vector3 = root_vehicle.global_position + Vector3.DOWN * 2
	var terrain_layer: int = 1 << 31
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	var terrain_query := PhysicsRayQueryParameters3D.create(raycast_from, raycast_to, terrain_layer)
	var terrain_hit: Dictionary = space_state.intersect_ray(terrain_query)
	
	if terrain_hit.is_empty():
		# Si queremos que el aceite se ponga exclusivamente sobre el suelo hay que taggearlo con la Layer 32.
		push_warning("Layer de terrain (32) no hitteado, defaulteando a cualquier cosa debajo del auto si es que hay")
	else:
		return terrain_hit
	
	var generic_query := PhysicsRayQueryParameters3D.create(raycast_from, raycast_to)
	return space_state.intersect_ray(generic_query)

func _spawn_oil_puddle(oil_puddle_basis: Basis, collision_point: Vector3, container: Node3D) -> void:
	var oil_puddle_instance: OilPuddlePowerUp = OIL_PUDDLE_SCENE.instantiate()
	container.add_child(oil_puddle_instance)
	
	# Nota: esta no es la forma matematicamente correcta de hacerlo, pero es simple y anda
	var z_fighting_offset: Vector3 = oil_puddle_basis.y * 0.001
	var spawn_position = collision_point + z_fighting_offset
	oil_puddle_instance.global_transform = Transform3D(oil_puddle_basis, spawn_position)

func can_spawn(root_vehicle: Car) -> bool:
	return not _get_floor_collision_data(root_vehicle).is_empty()


#
