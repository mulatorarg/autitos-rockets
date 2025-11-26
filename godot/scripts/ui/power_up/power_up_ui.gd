class_name PowerUpUI
extends Control

@export var _texture_rect: TextureRect
@export var _selected_color: ColorRect


func _ready() -> void:
	_selected_color.hide()

func initialize(icon: Texture2D) -> void:
	_texture_rect.texture = icon

func change_selection(is_selected: bool) -> void:
	_selected_color.visible = is_selected
