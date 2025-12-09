class_name PickeablePowerUp
extends Node3D

## Despues de cuanto tiempo vuelve a aparecer luego de ser pickeado
@export var _respawn_time: float = 5.0

@onready var _collision_shape: CollisionShape3D = $PickupAreaCollisionShape

var _respawn_timer := Timer.new()

const POWER_UP_PICKUP_SFX: AudioStream = preload("uid://bqog7rew5ttql")


func _ready() -> void:
	_respawn_timer.wait_time = _respawn_time
	_respawn_timer.one_shot = true
	_respawn_timer.timeout.connect(_on_respawn_timeout)
	add_child(_respawn_timer)

func get_power_up_type() -> PowerUpManager.PowerUpType:
	return PowerUpManager.PowerUpType.values().pick_random()

func destroy() -> void:
	AudioManager.play_sfx(POWER_UP_PICKUP_SFX, global_position)
	_collision_shape.disabled = true
	hide()
	_respawn_timer.start()

func _on_respawn_timeout() -> void:
	_collision_shape.disabled = false
	show()
