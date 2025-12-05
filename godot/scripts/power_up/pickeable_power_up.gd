class_name PickeablePowerUp
extends Node3D

@export var power_up_type: PowerUpManager.PowerUpType # testing
const POWER_UP_PICKUP_SFX: AudioStream = preload("uid://bqog7rew5ttql")


func get_power_up_type() -> PowerUpManager.PowerUpType:
	return power_up_type

func destroy() -> void:
	AudioManager.play_sfx(POWER_UP_PICKUP_SFX, global_position)
	queue_free()
