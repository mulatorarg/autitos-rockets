class_name OilPuddlePowerUp
extends Node3D

## Cuanto dura el charco en escena
@export var _puddle_lifetime: float = 10.0
## Cuanto dura el efecto sobre el auto que lo toca
@export var _effect_duration: float = 3.0
## Multiplicador al material fisico del auto, a valores bajos es mas resbaladizo
@export_range(0.1, 0.9, 0.01) var _friction_multiplier: float = 0.5


func _ready() -> void:
	_add_self_destruct_timer()

func _add_self_destruct_timer() -> void:
	var duration_timer := Timer.new()
	duration_timer.wait_time = _puddle_lifetime
	duration_timer.autostart = true
	duration_timer.one_shot = true
	duration_timer.timeout.connect(func(): self.queue_free(), CONNECT_ONE_SHOT)
	add_child(duration_timer)

func _on_trigger_area_body_entered(body: Car) -> void:
	body.apply_slip(_effect_duration, _friction_multiplier)





#
