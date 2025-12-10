extends Control
class_name ScreenMenu
## Panel de opciones para audio y video

signal closed

const FALLBACK_RESOLUTIONS := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440)
]
const TEST_SFX: AudioStream = preload("uid://cyp456in2y5o2")

@onready var music_slider: HSlider = $Panel/MarginContainer/VBoxContainer/MusicRow/HSlider
@onready var music_value_label: Label = $Panel/MarginContainer/VBoxContainer/MusicRow/ValueLabel
@onready var sfx_slider: HSlider = $Panel/MarginContainer/VBoxContainer/SfxRow/HSlider
@onready var sfx_value_label: Label = $Panel/MarginContainer/VBoxContainer/SfxRow/ValueLabel
@onready var resolution_option: OptionButton = $Panel/MarginContainer/VBoxContainer/ResolutionRow/OptionButton
@onready var vsync_checkbox: CheckBox = $Panel/MarginContainer/VBoxContainer/VsyncRow/CheckBox

var _resolutions: Array[Vector2i] = []


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_populate_resolutions()
	_refresh_values_from_settings()


func open() -> void:
	_refresh_values_from_settings()
	show()
	music_slider.grab_focus()


func close() -> void:
	hide()
	closed.emit()


func _populate_resolutions() -> void:
	_resolutions = GameManager.get_supported_resolutions()
	if _resolutions.is_empty():
		_resolutions = FALLBACK_RESOLUTIONS.duplicate()
	resolution_option.clear()
	for resolution in _resolutions:
		var label_text := "%dx%d" % [resolution.x, resolution.y]
		resolution_option.add_item(label_text)
		resolution_option.set_item_metadata(resolution_option.item_count - 1, resolution)


func _refresh_values_from_settings() -> void:
	var settings: Dictionary = GameManager.get_settings()
	music_slider.value = settings["music_volume"] * 100.0
	sfx_slider.value = settings["sfx_volume"] * 100.0
	music_value_label.text = "%d%%" % roundi(music_slider.value)
	sfx_value_label.text = "%d%%" % roundi(sfx_slider.value)
	_set_resolution_selection(settings["resolution"])
	vsync_checkbox.button_pressed = settings["vsync_enabled"]


func _set_resolution_selection(target: Vector2i) -> void:
	for index in range(resolution_option.item_count):
		var metadata: Variant = resolution_option.get_item_metadata(index)
		if metadata is Vector2i and metadata == target:
			resolution_option.select(index)
			return
	# Si no está en la lista, agregarlo al final
	var label_text := "%dx%d" % [target.x, target.y]
	resolution_option.add_item(label_text)
	resolution_option.set_item_metadata(resolution_option.item_count - 1, target)
	resolution_option.select(resolution_option.item_count - 1)


func _get_selected_resolution() -> Vector2i:
	var metadata: Variant = resolution_option.get_item_metadata(resolution_option.selected)
	if metadata is Vector2i:
		return metadata
	return FALLBACK_RESOLUTIONS[0]


func _on_music_value_changed(value: float) -> void:
	music_value_label.text = "%d%%" % roundi(value)
	AudioManager.change_music_volume(value / 100.0)


func _on_sfx_value_changed(value: float) -> void:
	sfx_value_label.text = "%d%%" % roundi(value)
	AudioManager.change_sfx_volume(value / 100.0)
	AudioManager.play_sfx(TEST_SFX, Vector3.ZERO)

func _on_save_button_pressed() -> void:
	var payload := {
		"music_volume": music_slider.value / 100.0,
		"sfx_volume": sfx_slider.value / 100.0,
		"resolution": _get_selected_resolution(),
		"vsync_enabled": vsync_checkbox.button_pressed
	}
	GameManager.update_settings(payload)
	GameManager.save_settings()
	close()


func _on_cancel_button_pressed() -> void:
	close()
