class_name ExplosiveMinePowerUp
extends Area3D

@export var _explosion_impulse: float = 25.0


func _on_area_entered(area: ImpactReceiver) -> void:
	area.receive_impact(self, Vector3.UP * _explosion_impulse)
	queue_free()
