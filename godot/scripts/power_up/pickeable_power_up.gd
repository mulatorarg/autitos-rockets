class_name PickeablePowerUp
extends Node3D

@export var power_up_type: PowerUpManager.PowerUpType # testing

func get_power_up_type() -> PowerUpManager.PowerUpType:
	return power_up_type

func destroy() -> void:
	queue_free()
