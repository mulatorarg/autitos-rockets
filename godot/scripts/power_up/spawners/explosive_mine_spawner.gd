class_name ExplosiveMineSpawner
extends PowerUpSpawner

const EXPLOSIVE_MINE_SCENE: PackedScene = preload("uid://djitbauvee1dj")
const SPAWN_OFFSET_DISTANCE := 3.0
const EXPLOSIVE_MINE_DROP_SFX: AudioStream = preload("uid://cyp456in2y5o2")


func get_type() -> PowerUpManager.PowerUpType:
	return PowerUpManager.PowerUpType.EXPLOSIVE_MINE

func spawn(root_vehicle: Car, active_power_ups_container: Node3D) -> void:
	AudioManager.play_sfx(EXPLOSIVE_MINE_DROP_SFX, global_position)
	
	var mine_instance: ExplosiveMinePowerUp = EXPLOSIVE_MINE_SCENE.instantiate()
	active_power_ups_container.add_child(mine_instance)
	
	var spawn_point: Vector3 = root_vehicle.global_position + -root_vehicle.get_forward() * SPAWN_OFFSET_DISTANCE
	mine_instance.global_position = spawn_point

func can_spawn(_root_vehicle: Car) -> bool:
	return true
