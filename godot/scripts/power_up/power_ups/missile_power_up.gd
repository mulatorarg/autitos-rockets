class_name MissilePowerUp
extends Node3D

## Que tan rapido viaja el misil
@export var _speed: float = 20.0
## Que tanto empuja al target al chocarlo
@export var _explosion_impulse: float = 15.0

var _direction: Vector3
var _target: Node3D

const LOOK_AT_ROTATION_SPEED := 10


func set_forward(forward: Vector3) -> void:
	_direction = forward

func _physics_process(delta: float) -> void:
	if _target != null:
		_direction = global_position.direction_to(_target.global_position)
		_smooth_look_at_target(delta)
	
	global_position += _direction * _speed * delta

func _on_target_detection_area_entered(area: ImpactReceiver) -> void:
	_target = area

func _on_target_hit_area_entered(area: ImpactReceiver) -> void:
	var push_direction: Vector3 = (_direction + Vector3.UP).normalized()
	var push_force: Vector3 = push_direction * _explosion_impulse
	
	area.receive_impact(self, push_force)
	queue_free()

func _smooth_look_at_target(delta: float) -> void:
	# Construir un nuevo basis que apunte a '_direction' (el target). O sea: basis forward == _direction
	# Es la rotacion final que el misil tiene que hacer para mirar hacia el target
	var target_basis := Basis.looking_at(_direction)
	
	# Rotacion actual y la final expresada en cuaterniones para no bardear con gimbal lock
	var q_current := Quaternion(global_transform.basis)
	var q_target  := Quaternion(target_basis)
	
	# Interpolar entre la rotacion actual y la final
	var q_new: Quaternion = q_current.slerp(q_target, clamp(delta * LOOK_AT_ROTATION_SPEED, 0.0, 1.0))
	
	# Reemplazar solo el Basis (rotacion), y no tocar la posicion
	global_transform.basis = Basis(q_new)




#
