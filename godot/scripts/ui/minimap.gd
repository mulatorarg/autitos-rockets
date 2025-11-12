extends Control

## Minimap: muestra posiciones de autos y trazado aproximado usando checkpoints

@export var panel_padding: int = 8
@export var track_color: Color = Color(1, 1, 1, 0.35)
@export var checkpoint_color: Color = Color(1, 1, 1, 0.6)
@export var player_color: Color = Color(0.1, 1.0, 0.1, 0.95)
@export var ai_color: Color = Color(0.2, 0.6, 1.0, 0.9)
@export var out_of_bounds_color: Color = Color(1.0, 0.4, 0.2, 0.9)
@export var draw_checkpoints: bool = true
@export var draw_track_lines: bool = true
@export var show_arrows: bool = true
@export var show_names: bool = true
@export var label_font: Font
@export var label_font_size: int = 12
@export var name_offset: Vector2 = Vector2(8, -8)

var _positions: Array = []           # Array de dicts: { car, laps, checkpoint, ... }
var _checkpoints_3d: Array[Node3D] = []
var _checkpoints_2d: Array[Vector2] = []
var _bounds_min: Vector2 = Vector2.ZERO
var _bounds_max: Vector2 = Vector2.ONE
var _have_bounds: bool = false

func _ready() -> void:
	if RaceManager:
		_checkpoints_3d = RaceManager.checkpoints
		_update_checkpoints_cache()
		RaceManager.positions_updated.connect(_on_positions_updated)
	queue_redraw()

func _process(_delta: float) -> void:
	# Redibujar suavemente
	# Actualizar cache de checkpoints si cambió (p.ej., al recargar pista)
	if RaceManager and _checkpoints_3d.size() != RaceManager.checkpoints.size():
		_checkpoints_3d = RaceManager.checkpoints
		_update_checkpoints_cache()
	queue_redraw()

func _on_positions_updated(positions: Array) -> void:
	_positions = positions
	# Recalcular bounds si aparecen autos fuera del rango de checkpoints
	if not _have_bounds:
		_compute_bounds()

func _update_checkpoints_cache() -> void:
	_checkpoints_2d.clear()
	for cp in _checkpoints_3d:
		var p: Vector3 = cp.global_position
		_checkpoints_2d.append(Vector2(p.x, p.z))
	_compute_bounds()

func _compute_bounds() -> void:
	var pts: Array[Vector2] = []
	pts.append_array(_checkpoints_2d)
	# Incluir posiciones actuales de autos si hay
	for entry in _positions:
		if entry.has("car") and is_instance_valid(entry.car):
			var c: Car = entry.car
			pts.append(Vector2(c.global_position.x, c.global_position.z))
	
	if pts.size() == 0:
		_have_bounds = false
		_bounds_min = Vector2(-50, -50)
		_bounds_max = Vector2(50, 50)
		return
	
	var min_x = pts[0].x
	var min_y = pts[0].y
	var max_x = pts[0].x
	var max_y = pts[0].y
	for v in pts:
		min_x = min(min_x, v.x)
		min_y = min(min_y, v.y)
		max_x = max(max_x, v.x)
		max_y = max(max_y, v.y)
	
	# Márgenes
	var padx = (max_x - min_x) * 0.1 + 1.0
	var pady = (max_y - min_y) * 0.1 + 1.0
	_bounds_min = Vector2(min_x - padx, min_y - pady)
	_bounds_max = Vector2(max_x + padx, max_y + pady)
	_have_bounds = true

func _map_world_to_minimap(world_x: float, world_z: float) -> Vector2:
	var rect := get_drawing_rect()
	var inner := Rect2(rect.position + Vector2(panel_padding, panel_padding), rect.size - Vector2(panel_padding * 2, panel_padding * 2))
	var sx = 1.0
	var sy = 1.0
	if _bounds_max.x - _bounds_min.x > 0.001:
		sx = (world_x - _bounds_min.x) / (_bounds_max.x - _bounds_min.x)
	if _bounds_max.y - _bounds_min.y > 0.001:
		sy = (world_z - _bounds_min.y) / (_bounds_max.y - _bounds_min.y)
	return inner.position + Vector2(sx * inner.size.x, sy * inner.size.y)

func get_drawing_rect() -> Rect2:
	return Rect2(Vector2.ZERO, size)

func _draw() -> void:
	# Fondo translúcido se espera que lo dibuje el Panel padre; aquí solo contenido
	# Dibujar track (líneas entre checkpoints)
	if draw_track_lines and _checkpoints_2d.size() >= 2:
		for i in range(_checkpoints_2d.size() - 1):
			var a = _map_world_to_minimap(_checkpoints_2d[i].x, _checkpoints_2d[i].y)
			var b = _map_world_to_minimap(_checkpoints_2d[i + 1].x, _checkpoints_2d[i + 1].y)
			draw_line(a, b, track_color, 2.0)
		# Cerrar loop si la pista es cerrada (heurística: último a primero)
		var a0 = _map_world_to_minimap(_checkpoints_2d[0].x, _checkpoints_2d[0].y)
		var an = _map_world_to_minimap(_checkpoints_2d[_checkpoints_2d.size() - 1].x, _checkpoints_2d[_checkpoints_2d.size() - 1].y)
		draw_line(an, a0, track_color * Color(1,1,1,0.5), 1.0)
	
	# Dibujar checkpoints
	if draw_checkpoints:
		for p in _checkpoints_2d:
			var c = _map_world_to_minimap(p.x, p.y)
			draw_circle(c, 2.0, checkpoint_color)
	
	# Dibujar autos
	for entry in _positions:
		if not entry.has("car") or not is_instance_valid(entry.car):
			continue
		var car: Car = entry.car
		var pos = _map_world_to_minimap(car.global_position.x, car.global_position.z)
		var is_player = (RaceManager.player_car == car)
		var color = player_color if is_player else ai_color
		var radius = 5.0 if is_player else 3.0
		draw_circle(pos, radius, color)
		if show_arrows:
			var fw: Vector3 = car.get_forward()
			var dir2 = Vector2(fw.x, fw.z).normalized()
			var tip = pos + dir2 * (radius + 6.0)
			draw_line(pos, tip, color, 2.0)
		if show_names:
			var font: Font = label_font
			if font == null:
				# Intento de obtener una fuente por defecto del tema
				if has_method("get_theme_default_font"):
					font = get_theme_default_font()
			if font != null:
				var label_text: String
				if car.has_method("get_display_name"):
					label_text = car.get_display_name()
				else:
					label_text = car.name
				draw_string(font, pos + name_offset, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, label_font_size, Color(1,1,1,0.95))
