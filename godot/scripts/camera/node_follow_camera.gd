class_name NodeFollowCamera
extends Camera3D

@export var lerp_speed := 4.0
@export var offset := Vector3.ZERO
@export var target := Node3D


func _physics_process(delta):
	var target_pos: Transform3D = target.global_transform.translated_local(offset)
	global_transform = global_transform.interpolate_with(target_pos, lerp_speed * delta)
	look_at(target.global_position)
