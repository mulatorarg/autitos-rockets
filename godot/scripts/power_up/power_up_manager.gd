class_name PowerUpManager
extends Node3D

@export var is_player: bool # TODO: Centralizar esto?

@onready var _spawners_container: Node3D = $Spawners

signal power_up_picked_up(type: PowerUpType)

var _active_power_ups_container: Node3D
var _all_spawners: Dictionary[PowerUpType, PowerUpSpawner] = {}
var _active_spawners: Array[PowerUpSpawner] = []
var _current_spawner_index: int
var _max_amount_of_active_power_ups := 3

enum PowerUpType { MISSILE, EXPLOSIVE_MINE, OIL_PUDDLE }


func _ready() -> void:
	_active_power_ups_container = get_tree().get_first_node_in_group("ActivePowerUpsContainer")
	if _active_power_ups_container == null:
		push_warning("Tiene que existir un Node3D en cualquier lugar de la escena con el grupo 'ActivePowerUpsContainer' para almacenar instancias de powerups en runtime")
	
	for spawner: PowerUpSpawner in _spawners_container.get_children():
		_all_spawners[spawner.get_type()] = spawner

func initialize(max_amount_of_active_power_ups: int) -> void:
	_max_amount_of_active_power_ups = max_amount_of_active_power_ups

func try_to_activate() -> void:
	if !_active_spawners.is_empty():
		_activate()

func swap_power_up() -> void:
	_move_active_spawner_index()

func _on_power_up_pickup_area_entered(pickeable_power_up: PickeablePowerUp) -> void:
	if _active_spawners.size() >= _max_amount_of_active_power_ups:
		return
	
	var type: PowerUpType = pickeable_power_up.get_power_up_type()
	
	_active_spawners.append(_all_spawners[type])
	pickeable_power_up.destroy()
	
	power_up_picked_up.emit(type)
	if is_player:
		PowerUpEventBus.raise_event_power_up_picked_up(type)
	
	if _active_spawners.size() == 1:
		_move_active_spawner_index()

func _activate() -> void:
	var spawner: PowerUpSpawner = _active_spawners[_current_spawner_index]
	
	if not spawner.can_spawn(owner):
		return
	
	spawner.spawn(owner, _active_power_ups_container)
	_active_spawners.erase(spawner)
	
	if is_player:
		PowerUpEventBus.raise_event_power_up_used(_current_spawner_index)
	
	_move_active_spawner_index()

func _move_active_spawner_index() -> void:
	if _active_spawners.is_empty():
		_current_spawner_index = 0
	else:
		_current_spawner_index = (_current_spawner_index + 1) % _active_spawners.size()
		
		if is_player:
			PowerUpEventBus.raise_event_selected_power_up_changed(_current_spawner_index)


#
