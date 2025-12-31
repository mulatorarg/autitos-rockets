class_name OilPuddleSpawner
extends PowerUpSpawner

const OIL_PUDDLE_SCENE: PackedScene = preload("uid://b70bn0vkqgxkv")
const SPAWN_OFFSET_DISTANCE := 15.0
const OIL_PUDDLE_DROP_SFX: AudioStream = preload("uid://cr2npcw7tdeea")
@export var terrain_layer_mask: int = 0 # If non-zero, will raycast only against this collision mask (useful to require a 'terrain' layer)


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
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	# If a specific terrain_mask is configured, try that first. If it's zero, skip and use generic raycast.
	if terrain_layer_mask != 0:
		var terrain_query := PhysicsRayQueryParameters3D.create(raycast_from, raycast_to, terrain_layer_mask)
		var terrain_hit: Dictionary = space_state.intersect_ray(terrain_query)
		if not terrain_hit.is_empty():
			return terrain_hit

	# Fallback: generic raycast (exclude the vehicle to avoid hitting itself)
	var generic_query := PhysicsRayQueryParameters3D.create(raycast_from, raycast_to)
	generic_query.exclude = [root_vehicle]
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
