class_name CarSFX
extends Node3D

@onready var _engine_sfx: AudioStreamPlayer3D = $EngineSFX
#@onready var _brake_sfx: AudioStreamPlayer3D = $BrakeSFX #TODO

const MIN_PITCH := 1.0
const MAX_PITCH := 4.0


func handle_sound(speed: float, max_speed: float, _is_breaking: bool) -> void:
	var new_pitch: float = speed / max_speed + MIN_PITCH
	_engine_sfx.pitch_scale = new_pitch
