extends Node
## Singleton para gestionar el estado global del juego

enum GameState {
	MENU,
	COUNTDOWN,
	RACING,
	PAUSED,
	FINISHED
}

var current_state: GameState = GameState.MENU

signal state_changed(new_state: GameState)


func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	
	current_state = new_state
	state_changed.emit(new_state)
	print("Game State cambió a: ", GameState.keys()[new_state])


func start_race() -> void:
	change_state(GameState.COUNTDOWN)


func begin_racing() -> void:
	change_state(GameState.RACING)


func pause_game() -> void:
	if current_state == GameState.RACING:
		change_state(GameState.PAUSED)
		get_tree().paused = true


func resume_game() -> void:
	if current_state == GameState.PAUSED:
		change_state(GameState.RACING)
		get_tree().paused = false


func finish_race() -> void:
	change_state(GameState.FINISHED)


func restart_race() -> void:
	RaceManager.reset_state()

	var tree := get_tree()
	if tree:
		tree.reload_current_scene()
	else:
		push_warning("SceneTree no disponible al intentar reiniciar la carrera")
