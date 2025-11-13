class_name ImpactReceiver
extends Area3D

signal impacted(source: Node3D, force: Vector3)

func receive_impact(source: Node3D, force: Vector3) -> void:
	impacted.emit(source, force)
