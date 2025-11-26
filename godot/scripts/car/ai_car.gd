class_name AICar
extends Car
## Auto controlado por IA usando Navigation3D y siguiendo checkpoints

@export var ai_reaction_time: float = 0.01  ## Tiempo de reacción de la IA (más bajo = más rápido)
@export var ai_steering_smoothness: float = 8.0  ## Suavidad en el giro (más alto = más rápido hacia el objetivo)
@export_range(0.5, 1.5, 0.01) var ai_target_speed: float = 1.1  ## Velocidad objetivo normalizada
@export_range(0.5, 1.0, 0.01) var ai_corner_speed_floor: float = 0.8  ## Porcentaje mínimo de velocidad en curvas
@export var ai_brake_distance: float = 8.0  ## Distancia para empezar a frenar en curvas
@export var ai_obstacle_avoidance_strength: float = 2.0  ## Fuerza de evasión de obstáculos

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var current_target_position: Vector3
var desired_speed: float = 1.0
var desired_turn: float = 0.0
var reaction_timer: float = 0.0
var _has_missile_power_up: bool


#Registrar este auto como enemigo en el RaceManager
func _ready() -> void:
	super._ready()
	RaceManager.register_car(self, false)
	
	# Configurar NavigationAgent3D
	navigation_agent.path_desired_distance = 1.0
	navigation_agent.target_desired_distance = 2.0
	navigation_agent.max_speed = 50.0
	navigation_agent.avoidance_enabled = true
	navigation_agent.debug_enabled = true
	
	# Esperar a que el NavigationServer esté listo
	call_deferred("_setup_navigation")
	
	_power_up_manager.power_up_picked_up.connect(_on_power_up_picked_up)

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


## Actualiza el objetivo de navegación al siguiente checkpoint
func _update_target_checkpoint() -> void:
	var checkpoint_index = RaceManager.get_car_checkpoint(self)
	
	if RaceManager.checkpoints.size() == 0:
		print("%s: No hay checkpoints disponibles" % name)
		return
	
	var target_checkpoint_index = checkpoint_index % RaceManager.checkpoints.size()
	if target_checkpoint_index < RaceManager.checkpoints.size():
		var target_checkpoint = RaceManager.checkpoints[target_checkpoint_index]
		current_target_position = target_checkpoint.global_position
		navigation_agent.target_position = current_target_position
		# print("%s: Objetivo checkpoint %d en posición %v" % [name, target_checkpoint_index, current_target_position])


## Actualiza el input de la IA basado en la navegación
func _update_ai_input() -> void:
	if GameManager.current_state != GameManager.GameState.RACING:
		desired_speed = 0.0
		desired_turn = 0.0
		return
	
	_update_target_checkpoint()
	
	if not navigation_agent.is_navigation_finished():
		var next_path_position: Vector3 = navigation_agent.get_next_path_position()
		var direction_to_target: Vector3 = (next_path_position - global_position).normalized()

		# Usar el forward del modelo (no el rigidbody) para evitar desincronización
		var forward: Vector3 = get_forward()
		var angle_to_target: float = forward.signed_angle_to(direction_to_target, Vector3.UP)

		# Determinar giro deseado (normalizado) y limitar micro oscilaciones
		var normalized_turn: float = angle_to_target / deg_to_rad(_steering)
		# Evitar jitter en ángulos muy pequeños
		if abs(normalized_turn) < 0.02:
			normalized_turn = 0.0
		desired_turn = clamp(normalized_turn, -1.0, 1.0)

		# Determinar velocidad basada en severidad de la curva
		var angle_severity: float = abs(angle_to_target)
		if angle_severity > deg_to_rad(60): # curva muy cerrada
			desired_speed = ai_target_speed * 0.8
		elif angle_severity > deg_to_rad(40): # curva cerrada
			desired_speed = ai_target_speed * 0.92
		elif angle_severity > deg_to_rad(20): # curva media
			desired_speed = ai_target_speed * 0.98
		else: # recta o curva suave
			desired_speed = ai_target_speed

		desired_speed = max(desired_speed, ai_target_speed * ai_corner_speed_floor)

		# Evasión de obstáculos adicional
		_apply_obstacle_avoidance()
	else:
		desired_speed = 0.0
		desired_turn = 0.0


## Detecta obstáculos cercanos y ajusta el giro para evitarlos
func _apply_obstacle_avoidance() -> void:
	var space_state = get_world_3d().direct_space_state
	var forward = -global_transform.basis.z
	
	# Raycast hacia adelante para detectar obstáculos
	var ray_distance = 4.0
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
		
	# Reducir velocidad (menos agresivo)
	desired_speed *= 0.92


func _read_movement_input() -> void:
	# Suavizar el cambio de velocidad
	_speed_input = lerp(_speed_input, desired_speed, ai_steering_smoothness * get_process_delta_time())
	
	# La IA no frena manualmente salvo velocidades muy bajas
	_is_braking = desired_speed < 0.1
	_is_reversing = false


func _read_steer_input() -> void:
	# Suavizar el giro
	var target_turn = desired_turn * deg_to_rad(_steering)
	_turn_input = lerp(_turn_input, target_turn, ai_steering_smoothness * get_process_delta_time())

func _on_power_up_picked_up(type: PowerUpManager.PowerUpType) -> void:
	if type == PowerUpManager.PowerUpType.MISSILE:
		_has_missile_power_up = true
	else:
		_has_missile_power_up = false
		_power_up_manager.try_to_activate()

func _on_missile_trigger_area_area_entered(_area: ImpactReceiver) -> void:
	if _has_missile_power_up:
		_power_up_manager.try_to_activate()
		_has_missile_power_up = false




#
