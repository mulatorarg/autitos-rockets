class_name Track
extends Node3D

## Escena base para pistas de carreras

@export var total_laps: int = 3  ## Número de vueltas de la carrera
@export var checkpoints_node: Node3D  ## Nodo que contiene los checkpoints
@export var start_countdown_on_ready: bool = true  ## Iniciar cuenta regresiva al cargar

var checkpoints: Array[Node3D] = []


func _ready() -> void:
	_setup_checkpoints()
	_setup_race()
	
	if start_countdown_on_ready:
		GameManager.start_race()


func _setup_checkpoints() -> void:
	"""Recolecta todos los checkpoints hijos y los ordena"""
	if checkpoints_node == null:
		checkpoints_node = get_node_or_null("Checkpoints")
	
	if checkpoints_node == null:
		push_warning("No se encontró el nodo de checkpoints en el Track")
		return
	
	# Recolectar todos los checkpoints
	for child in checkpoints_node.get_children():
		if child is Checkpoint:
			checkpoints.append(child)
	
	# Ordenar por índice
	checkpoints.sort_custom(func(a, b): return a.checkpoint_index < b.checkpoint_index)
	
	print("Track configurado con %d checkpoints" % checkpoints.size())


func _setup_race() -> void:
	"""Configura el RaceManager con los datos de esta pista"""
	RaceManager.setup_race(total_laps, checkpoints)


func _input(event: InputEvent) -> void:
	# Reiniciar con R
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_R and event.pressed):
		if GameManager.current_state == GameManager.GameState.FINISHED:
			GameManager.restart_race()
