extends Node
## Singleton para gestionar el estado de la carrera: vueltas, checkpoints, posiciones

signal lap_completed(car: Car, lap_number: int)
signal checkpoint_passed(car: Car, checkpoint_index: int)
signal race_completed(car: Car, final_time: float)
signal positions_updated(positions: Array)

# Configuración de la carrera (establecida por cada nivel)
var total_laps: int = 3
var checkpoints: Array[Node3D] = []

# Estado de cada auto
var car_data: Dictionary = {}  # car_node -> {laps: int, current_checkpoint: int, total_checkpoints: int, finished: bool, finish_time: float}
var race_start_time: float = 0.0
var player_car: Car = null

# Posiciones calculadas
var race_positions: Array = []  # Array de {car: Car, position: int, laps: int, checkpoint: int, distance: float}


func _ready() -> void:
	GameManager.state_changed.connect(_on_game_state_changed)

## Llamado por cada nivel para configurar la carrera
func setup_race(laps: int, checkpoint_nodes: Array[Node3D]) -> void:
	total_laps = laps
	checkpoints = checkpoint_nodes
	race_positions.clear()
	race_start_time = 0.0
	# Reiniciar estado de autos ya registrados sin perder el registro
	# Importante: los hijos (autos) hacen register_car en _ready antes que este _ready de Track,
	# por lo que limpiar car_data aquí borra esos registros y provoca warnings.
	for car in car_data.keys():
		car_data[car].laps = 0
		car_data[car].current_checkpoint = 0
		car_data[car].total_checkpoints = 0
		car_data[car].finished = false
		car_data[car].finish_time = 0.0
	print("Datos Carrera: %d vueltas, %d checkpoints" % [total_laps, checkpoints.size()])


## Registra un auto en la carrera
func register_car(car: Car, is_player: bool = false) -> void:
	car_data[car] = {
		"laps": 0,
		"current_checkpoint": 0,
		"total_checkpoints": 0,
		"finished": false,
		"finish_time": 0.0,
		"is_player": is_player
	}
	
	if is_player:
		player_car = car
	
	# Eliminar referencia cuando el auto salga del árbol (e.g., al recargar escena)
	if not car.tree_exited.is_connected(_on_car_tree_exited):
		car.tree_exited.connect(_on_car_tree_exited.bind(car))
	
	print("Auto Registrado: ", car.name, " (Player: ", is_player, ")")


## Llamado cuando un auto pasa por un checkpoint
func on_checkpoint_passed(car: Car, checkpoint_index: int) -> void:
	if not is_instance_valid(car):
		return
	if car not in car_data:
		# Auto no registrado (posible orden de inicialización). Registrar de forma segura.
		var is_player := car is PlayerCar
		print("Info: Auto %s no registrado detectado en checkpoint %d. Registrando (Player: %s)." % [car.name, checkpoint_index, str(is_player)])
		register_car(car, is_player)
	
	var data = car_data[car]
	
	# Verificar que sea el checkpoint correcto (en orden)
	var expected_checkpoint = data.current_checkpoint % checkpoints.size()
	if checkpoint_index != expected_checkpoint:
		print("%s pasó checkpoint %d pero esperaba %d (ignorado)" % [car.name, checkpoint_index, expected_checkpoint])
		return  # Checkpoint fuera de orden
	
	data.current_checkpoint += 1
	data.total_checkpoints += 1
	
	checkpoint_passed.emit(car, checkpoint_index)
	print("%s pasó checkpoint %d correctamente" % [car.name, checkpoint_index])
	
	# Verificar si completó una vuelta
	if data.current_checkpoint >= checkpoints.size():
		data.current_checkpoint = 0
		data.laps += 1
		lap_completed.emit(car, data.laps)
		print("%s completó la vuelta %d" % [car.name, data.laps])
		
		# Verificar si terminó la carrera
		if data.laps >= total_laps and not data.finished:
			data.finished = true
			data.finish_time = Time.get_ticks_msec() / 1000.0 - race_start_time
			race_completed.emit(car, data.finish_time)
			print("%s terminó la carrera! Tiempo: %.2fs" % [car.name, data.finish_time])
			
			# Si el jugador terminó, cambiar estado del juego
			if data.is_player:
				GameManager.finish_race()
	
	_update_positions()


func get_car_lap(car: Car) -> int:
	if car in car_data:
		return car_data[car].laps
	return 0


func get_car_checkpoint(car: Car) -> int:
	if car in car_data:
		return car_data[car].current_checkpoint
	return 0


## Obtiene la posición actual del auto en la carrera (1 = primero)
func get_car_position(car: Car) -> int:
	for i in range(race_positions.size()):
		if race_positions[i].car == car:
			return i + 1
	return race_positions.size() + 1


## Obtiene el tiempo transcurrido desde el inicio de la carrera
func get_race_time() -> float:
	if race_start_time == 0.0:
		return 0.0
	return Time.get_ticks_msec() / 1000.0 - race_start_time


func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.RACING:
		race_start_time = Time.get_ticks_msec() / 1000.0


## Actualiza las posiciones de todos los autos
func _update_positions() -> void:
	race_positions.clear()
	
	var to_remove: Array = []
	for car in car_data.keys():
		if not is_instance_valid(car):
			to_remove.append(car)
			continue
		var data = car_data[car]
		var progress = data.laps + (data.current_checkpoint / float(checkpoints.size()))
		
		# Calcular distancia al siguiente checkpoint para desempate
		var distance_to_next = 0.0
		if checkpoints.size() > 0:
			var next_checkpoint_idx = data.current_checkpoint % checkpoints.size()
			if next_checkpoint_idx < checkpoints.size():
				distance_to_next = car.global_position.distance_to(checkpoints[next_checkpoint_idx].global_position)
		
		race_positions.append({
			"car": car,
			"laps": data.laps,
			"checkpoint": data.current_checkpoint,
			"progress": progress,
			"distance": distance_to_next,
			"finished": data.finished
		})
	
	# Limpiar autos inválidos (de escenas anteriores)
	for c in to_remove:
		car_data.erase(c)
	
	# Ordenar por: terminados primero, luego por progreso (vueltas + checkpoints), luego por distancia al siguiente checkpoint
	race_positions.sort_custom(func(a, b):
		if a.finished != b.finished:
			return a.finished  # Los que terminaron van primero
		if a.progress != b.progress:
			return a.progress > b.progress
		return a.distance < b.distance  # Menor distancia = más cerca = mejor posición
	)
	
	positions_updated.emit(race_positions)


# Manejar remoción de autos del árbol para mantener el diccionario limpio
func _on_car_tree_exited(car: Car) -> void:
	if car in car_data:
		car_data.erase(car)
	if player_car == car:
		player_car = null


func get_player_stats() -> Dictionary:
## Obtiene estadísticas del jugador
	if player_car == null or player_car not in car_data:
		return {
			"laps": 0,
			"checkpoint": 0,
			"position": 0,
			"speed": 0.0,
			"finished": false,
			"time": 0.0
		}
	
	return {
		"laps": car_data[player_car].laps,
		"checkpoint": car_data[player_car].current_checkpoint,
		"position": get_car_position(player_car),
		"speed": player_car.get_speed() if player_car.has_method("get_speed") else 0.0,
		"finished": car_data[player_car].finished,
		"time": get_race_time()
	}
