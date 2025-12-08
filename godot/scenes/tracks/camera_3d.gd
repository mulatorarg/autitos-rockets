extends Camera3D

@export var target: Node3D

func _process(_delta):
	if target:
		look_at(target.global_position, Vector3.UP)
