extends Node

signal power_up_picked_up(type: PowerUpManager.PowerUpType)
signal power_up_used(index: int)
signal selected_power_up_changed(index: int)


func raise_event_power_up_picked_up(type: PowerUpManager.PowerUpType) -> void:
	power_up_picked_up.emit(type)

func raise_event_power_up_used(index: int) -> void:
	power_up_used.emit(index)

func raise_event_selected_power_up_changed(index: int) -> void:
	selected_power_up_changed.emit(index)
