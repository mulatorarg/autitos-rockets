extends SubViewport

## Minimap superior: usa una cámara ortográfica hacia abajo para mostrar la pista
## Se adjunta a un SubViewport dentro del HUD. Renderiza el mismo World3D de la escena actual.

@onready var cam: Camera3D = $MinimapCamera

# Ajustes de cámara/zoom
@export var ortho_size_multiplier: float = 1.25  # >1.0 aleja (zoom out), <1.0 acerca
@export var camera_height: float = 280.0         # Altura de la cámara sobre el centro

var _checkpoints: Array[Node3D] = []
var _bounds_min: Vector3
var _bounds_max: Vector3

func _ready() -> void:
	# Compartir mundo con la escena principal
	if get_viewport():
		world_3d = get_viewport().world_3d
	# Configurar cámara en ortográfica
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.near = 0.1
	cam.far = 2000.0
	# Evitar banding en profundidad por vista superior
	_update_bounds_and_camera()
	# Si el SubViewport está dentro de un SubViewportContainer con stretch=true,
	# el tamaño lo gestiona el contenedor. No forzar size aquí para evitar warnings.
	# Escuchar actualizaciones de posiciones para reajustar si hiciera falta
	if RaceManager and RaceManager.positions_updated.is_connected(_on_positions_updated) == false:
		RaceManager.positions_updated.connect(_on_positions_updated)

func _on_positions_updated(_positions: Array) -> void:
	# Si no hay bounds aún o la pista cambió, reconfigurar
	if _checkpoints.size() != RaceManager.checkpoints.size():
		_update_bounds_and_camera()

## No es necesario ajustar size manualmente; el contenedor lo gestiona.

func _update_bounds_and_camera() -> void:
	# Obtener checkpoints actuales
	_checkpoints.clear()
	_checkpoints = RaceManager.checkpoints.duplicate()
	var have_any := _checkpoints.size() > 0
	var min_x := 0.0
	var min_z := 0.0
	var max_x := 0.0
	var max_z := 0.0
	if have_any:
		min_x = _checkpoints[0].global_position.x
		max_x = _checkpoints[0].global_position.x
		min_z = _checkpoints[0].global_position.z
		max_z = _checkpoints[0].global_position.z
		for cp in _checkpoints:
			var p = cp.global_position
			min_x = min(min_x, p.x)
			min_z = min(min_z, p.z)
			max_x = max(max_x, p.x)
			max_z = max(max_z, p.z)
	else:
		# Fallback: centrar en el jugador si existe
		if RaceManager.player_car and is_instance_valid(RaceManager.player_car):
			var p3 = RaceManager.player_car.global_position
			min_x = p3.x - 50
			max_x = p3.x + 50
			min_z = p3.z - 50
			max_z = p3.z + 50
			have_any = true
		else:
			# Defaults
			min_x = -50
			max_x =  50
			min_z = -50
			max_z =  50
			have_any = true
	
	_bounds_min = Vector3(min_x, 0, min_z)
	_bounds_max = Vector3(max_x, 0, max_z)
	var center = (_bounds_min + _bounds_max) * 0.5
	# Márgenes
	var extent_x = (max_x - min_x) * 0.6 + 30.0
	var extent_z = (max_z - min_z) * 0.6 + 30.0
	var half_size = max(extent_x, extent_z)
	# Colocar cámara arriba, mirando hacia abajo
	cam.transform.origin = Vector3(center.x, camera_height, center.z)
	cam.transform.basis = Basis() # reset
	cam.look_at(Vector3(center.x, 0.0, center.z), Vector3(0, 0, -1))
	cam.size = half_size * ortho_size_multiplier
