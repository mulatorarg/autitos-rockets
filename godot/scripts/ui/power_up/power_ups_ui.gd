class_name PowerUpsUI
extends Control

@export var _power_ups_container: Container

const POWER_UP_UI_SCENE: PackedScene = preload("uid://cpct1p0oy54vi")
const ICON_BY_TYPE: Dictionary[PowerUpManager.PowerUpType, Texture2D] = {
	PowerUpManager.PowerUpType.MISSILE: preload("uid://c867v1lixqhpj"),
	PowerUpManager.PowerUpType.EXPLOSIVE_MINE: preload("uid://dowfgv7u3rpkk"),
	PowerUpManager.PowerUpType.OIL_PUDDLE: preload("uid://cyp7kysaab5y6"),
}


func _ready() -> void:
	PowerUpEventBus.power_up_picked_up.connect(_on_power_up_picked_up)
	PowerUpEventBus.power_up_used.connect(_on_power_up_used)
	PowerUpEventBus.selected_power_up_changed.connect(_on_selected_power_up_changed)
	
	for c in _power_ups_container.get_children():
		c.queue_free()

func _on_power_up_picked_up(type: PowerUpManager.PowerUpType) -> void:
	var new_power_up_ui: PowerUpUI = POWER_UP_UI_SCENE.instantiate()
	_power_ups_container.add_child(new_power_up_ui)
	new_power_up_ui.initialize(ICON_BY_TYPE[type])

func _on_power_up_used(index: int) -> void:
	_power_ups_container.get_children()[index].queue_free()

func _on_selected_power_up_changed(index: int) -> void:
	var power_ups: Array = _power_ups_container.get_children().filter(func(c: Node): return !c.is_queued_for_deletion())
	for i: int in range(power_ups.size()):
		var power_up: PowerUpUI = power_ups[i]
		var is_selected: bool = i == index
		power_up.change_selection(is_selected)

func _exit_tree() -> void:
	PowerUpEventBus.power_up_picked_up.disconnect(_on_power_up_picked_up)
	PowerUpEventBus.power_up_used.disconnect(_on_power_up_used)
	PowerUpEventBus.selected_power_up_changed.disconnect(_on_selected_power_up_changed)








#
