class_name PowerUpManager
extends Node3D

@onready var _spawners_container: Node3D = $Spawners

var _spawners: Dictionary[PowerUpType, PowerUpSpawner] = {}
var _current_power_up_spawner: PowerUpSpawner
var _active_power_ups_container: Node3D

enum PowerUpType { MISSILE, EXPLOSIVE_MINE, OIL_PUDDLE }


func _ready() -> void:
	_active_power_ups_container = get_tree().get_first_node_in_group("ActivePowerUpsContainer")
	
	for spawner: PowerUpSpawner in _spawners_container.get_children():
		_spawners[spawner.get_type()] = spawner

func _unhandled_input(event: InputEvent) -> void:
	if _can_activate(event):
		_activate()

func _on_power_up_pickup_area_entered(power_up: PickeablePowerUp) -> void:
	_current_power_up_spawner = _spawners[power_up.get_power_up_type()]
	power_up.destroy()

func _can_activate(event: InputEvent) -> bool:
	return event.is_action_pressed("activate_power_up") && _current_power_up_spawner != null

func _activate() -> void:
	_current_power_up_spawner.spawn(owner, _active_power_ups_container)
	#_current_power_up_spawner = null




#
