class_name Checkpoint
extends Node3D

## Checkpoint que detecta cuando un auto pasa por él

@export var checkpoint_index: int = 0  ## Índice del checkpoint en la secuencia
## Color para visualización en el editor (reservado para futura implementación)
@warning_ignore("unused_private_class_variable")
@export var debug_color: Color = Color.GREEN
@export var show_debug: bool = false
@onready var area_3d: Area3D = $Area3D
@onready var debug_mesh: MeshInstance3D = $DebugMesh


func _ready() -> void:
	area_3d.body_entered.connect(_on_body_entered)
	debug_mesh.visible = show_debug
	
	# Cambiar color del debug mesh según el índice
	if show_debug and debug_mesh.material_override:
		var color = Color.from_hsv(checkpoint_index / 10.0, 0.8, 1.0, 0.3)
		debug_mesh.material_override.albedo_color = color
	
	print("Checkpoint %d inicializado en posición %v" % [checkpoint_index, global_position])


func _on_body_entered(body: Node3D) -> void:
	"""Detecta cuando un auto pasa por el checkpoint"""
	print("Checkpoint %d: Detectó body %s (es Car: %s)" % [checkpoint_index, body.name, body is Car])
	if body is Car:
		RaceManager.on_checkpoint_passed(body, checkpoint_index)
