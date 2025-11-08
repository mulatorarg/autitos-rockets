class_name AICar
extends Car

## Auto controlado por IA usando Navigation3D y siguiendo checkpoints

@export var ai_reaction_time: float = 0.1  ## Tiempo de reacción de la IA (más bajo = más rápido)
@export var ai_steering_smoothness: float = 3.0  ## Suavidad en el giro (más alto = más suave)
@export var ai_target_speed: float = 0.9  ## Velocidad objetivo (0.0 a 1.0)
@export var ai_brake_distance: float = 8.0  ## Distancia para empezar a frenar en curvas
@export var ai_obstacle_avoidance_strength: float = 2.0  ## Fuerza de evasión de obstáculos

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var current_target_position: Vector3
var desired_speed: float = 1.0
var desired_turn: float = 0.0
var reaction_timer: float = 0.0


func _ready() -> void:
	# Registrar este auto como enemigo en el RaceManager
	RaceManager.register_car(self, false)
	
	# Configurar NavigationAgent3D
	navigation_agent.path_desired_distance = 1.0
	navigation_agent.target_desired_distance = 2.0
	navigation_agent.max_speed = 20.0
	navigation_agent.avoidance_enabled = true
	navigation_agent.debug_enabled = true  # Activar debug para ver el path
	
	# Esperar a que el NavigationServer esté listo
	call_deferred("_setup_navigation")


func _setup_navigation() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame  # Esperar un frame adicional
	print("%s: NavigationAgent listo" % name)
	_update_target_checkpoint()


func _process(delta: float) -> void:
	super._process(delta)
	
	# Actualizar objetivo de navegación
	reaction_timer += delta
	if reaction_timer >= ai_reaction_time:
		reaction_timer = 0.0
		_update_ai_input()


func _update_target_checkpoint() -> void:
	"""Actualiza el objetivo de navegación al siguiente checkpoint"""
	var checkpoint_index = RaceManager.get_car_checkpoint(self)
	
	if RaceManager.checkpoints.size() == 0:
		print("%s: No hay checkpoints disponibles" % name)
		return
	
	var target_checkpoint_index = checkpoint_index % RaceManager.checkpoints.size()
	if target_checkpoint_index < RaceManager.checkpoints.size():
		var target_checkpoint = RaceManager.checkpoints[target_checkpoint_index]
		current_target_position = target_checkpoint.global_position
		navigation_agent.target_position = current_target_position
		print("%s: Objetivo checkpoint %d en posición %v" % [name, target_checkpoint_index, current_target_position])


func _update_ai_input() -> void:
	"""Actualiza el input de la IA basado en la navegación"""
	if GameManager.current_state != GameManager.GameState.RACING:
		desired_speed = 0.0
		desired_turn = 0.0
		return
	
	_update_target_checkpoint()
	
	if not navigation_agent.is_navigation_finished():
		var next_path_position: Vector3 = navigation_agent.get_next_path_position()
		var direction_to_target: Vector3 = (next_path_position - global_position).normalized()
		
		# Calcular ángulo hacia el objetivo
		var forward = -global_transform.basis.z
		var angle_to_target = forward.signed_angle_to(direction_to_target, Vector3.UP)
		
		# Determinar giro deseado
		desired_turn = clamp(angle_to_target / deg_to_rad(_steering), -1.0, 1.0)
		
		# Determinar velocidad deseada basada en el ángulo
		var angle_severity = abs(angle_to_target)
		if angle_severity > deg_to_rad(45):
			# Curva cerrada: reducir velocidad
			desired_speed = ai_target_speed * 0.4
		elif angle_severity > deg_to_rad(25):
			# Curva moderada
			desired_speed = ai_target_speed * 0.7
		else:
			# Recta: velocidad máxima
			desired_speed = ai_target_speed
		
		# Evasión de obstáculos adicional
		_apply_obstacle_avoidance()
	else:
		desired_speed = 0.0
		desired_turn = 0.0


func _apply_obstacle_avoidance() -> void:
	"""Detecta obstáculos cercanos y ajusta el giro para evitarlos"""
	var space_state = get_world_3d().direct_space_state
	var forward = -global_transform.basis.z
	
	# Raycast hacia adelante para detectar obstáculos
	var ray_distance = 5.0
	var ray_start = global_position + Vector3.UP * 0.5
	var ray_end = ray_start + forward * ray_distance
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.exclude = [self]
	query.collision_mask = 1  # Capa de obstáculos
	
	var result = space_state.intersect_ray(query)
	if result:
		# Hay un obstáculo, intentar esquivar hacia un lado
		var obstacle_position = result.position
		var to_obstacle = (obstacle_position - global_position).normalized()
		var right = global_transform.basis.x
		
		# Determinar si esquivar a la izquierda o derecha
		var dot = right.dot(to_obstacle)
		if dot > 0:
			# Obstáculo a la derecha, girar a la izquierda
			desired_turn -= ai_obstacle_avoidance_strength * 0.5
		else:
			# Obstáculo a la izquierda, girar a la derecha
			desired_turn += ai_obstacle_avoidance_strength * 0.5
		
		# Reducir velocidad
		desired_speed *= 0.6


func _read_movement_input() -> void:
	# Suavizar el cambio de velocidad
	_speed_input = lerp(_speed_input, desired_speed, ai_steering_smoothness * get_process_delta_time())
	
	# La IA no frena manualmente, solo reduce velocidad
	_is_braking = desired_speed < 0.3
	_is_reversing = false


func _read_steer_input() -> void:
	# Suavizar el giro
	var target_turn = desired_turn * deg_to_rad(_steering)
	_turn_input = lerp(_turn_input, target_turn, ai_steering_smoothness * get_process_delta_time())
