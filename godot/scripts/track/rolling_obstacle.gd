extends RigidBody3D
class_name RollingObstacle

## Obstáculo esférico que se mueve horizontalmente y rebota verticalmente.
## Combina movimiento sinusoidal lateral con saltos periódicos para crear un desafío dinámico.
## Los autos deben esquivar este obstáculo en movimiento.

# Configuración exportada del movimiento

## Distancia total del movimiento horizontal en metros
@export var movement_distance := 10.0

## Velocidad del movimiento sinusoidal (mayor = más rápido)
@export var movement_speed := 2.0

## Dirección del movimiento horizontal (ej: Vector3.RIGHT, Vector3.FORWARD)
@export var direction := Vector3.RIGHT

## Fuerza del impulso hacia arriba en Newtons (mayor = salto más alto)
@export var bounce_force := 600.0

## Intervalo en segundos entre cada rebote
@export var bounce_interval := 2.0

# Variables internas de estado

## Posición inicial del obstáculo para calcular el movimiento sinusoidal
var start_position: Vector3

## Tiempo acumulado para el cálculo del movimiento sinusoidal
var time_passed := 0.0

## Temporizador para controlar los intervalos de rebote
var bounce_timer := 0.0

## Indica si el obstáculo está tocando el suelo
var is_grounded := false


## Inicialización del obstáculo.
## Guarda la posición inicial y configura las propiedades físicas para rebotes.
func _ready() -> void:
	# Guardar posición inicial como referencia para el movimiento
	start_position = global_position
	
	# Configurar material físico para rebotes naturales
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.8  # Alto rebote
	physics_material_override.friction = 0.3  # Baja fricción para rodar
	
	# Conectar señal de colisión
	body_entered.connect(_on_body_entered)


## Actualiza el movimiento y rebotes del obstáculo cada frame de física.
## Combina movimiento horizontal sinusoidal con saltos verticales periódicos.
func _physics_process(delta: float) -> void:
	# Actualizar contadores de tiempo
	time_passed += delta * movement_speed
	bounce_timer += delta
	
	# Calcular posición objetivo usando función sinusoidal para movimiento suave
	var offset = sin(time_passed) * movement_distance / 2.0
	var target_position = start_position + direction * offset
	
	# Calcular dirección hacia la posición objetivo (solo componente horizontal)
	var direction_to_target = target_position - global_position
	direction_to_target.y = 0  # Ignorar diferencia vertical
	
	# Aplicar fuerza para mover horizontalmente hacia el objetivo
	if direction_to_target.length() > 0.1:
		apply_central_force(direction_to_target.normalized() * 50.0)
	
	# Verificar si el obstáculo está en el suelo
	check_ground()
	
	# Si está en el suelo y ha pasado el intervalo, aplicar rebote
	if is_grounded and bounce_timer >= bounce_interval:
		apply_central_impulse(Vector3.UP * bounce_force)
		bounce_timer = 0.0  # Reiniciar temporizador


## Verifica si el obstáculo está tocando el suelo usando raycast.
## Actualiza la variable is_grounded.
func check_ground() -> void:
	# Configurar raycast desde el centro hacia abajo
	var space_state = get_world_3d().direct_space_state
	var ray_origin = global_position
	var ray_target = global_position + Vector3.DOWN * 1.2  # 1.2m hacia abajo
	
	# Crear query de raycast excluyendo este obstáculo
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
	query.exclude = [self]
	
	# Ejecutar raycast y actualizar estado
	var result = space_state.intersect_ray(query)
	is_grounded = result.size() > 0


## Callback cuando el obstáculo colisiona con otro cuerpo.
## Actualmente no implementado, pero mantiene las propiedades de rebote del material físico.
## @param _body: El cuerpo con el que colisionó
func _on_body_entered(_body: Node) -> void:
	# Las propiedades de rebote del physics_material manejan las colisiones
	pass
