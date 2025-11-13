@abstract
class_name CarModel
extends Node3D

var _front_wheels: Array[Node3D]

# Etiqueta 3D del nombre sobre el modelo
@export var show_name_label_3d: bool = true
@export var name_label_offset: Vector3 = Vector3(0, 2.2, 0)
@export var name_label_color: Color = Color(1, 1, 1, 1)
@export var name_label_font: Font
@export var name_label_font_size: int = 24
@export var name_label_fixed_size: bool = true

var _name_label: Label3D
var _owner_car: Car

@abstract
func _get_front_wheels() -> Array[Node3D]

func _ready():
	_front_wheels = _get_front_wheels()
	_owner_car = (get_parent() as Car) if (get_parent() is Car) else null
	if show_name_label_3d:
		_create_name_label()

func _process(_delta: float) -> void:
	if _name_label != null and is_instance_valid(_name_label):
		# Actualizar texto si cambió
		if _owner_car != null and is_instance_valid(_owner_car):
			var want_text: String
			if _owner_car.has_method("get_display_name"):
				want_text = _owner_car.get_display_name()
			else:
				want_text = _owner_car.name
			if _name_label.text != want_text:
				_name_label.text = want_text
		# Orientar hacia la cámara si billboard no está disponible
		var cam: Camera3D = get_viewport().get_camera_3d() if get_viewport() else null
		if cam != null:
			# Si la propiedad billboard existe y está activa, no hace falta
			var is_billboard := false
			for p in _name_label.get_property_list():
				if p["name"] == "billboard":
					is_billboard = true
					break
			if not is_billboard:
				_name_label.look_at(cam.global_transform.origin, Vector3.UP)

func rotate_front_wheels(angle: float) -> void:
	for wheel: Node3D in _front_wheels:
		wheel.rotation.y = angle

## CarPivot se encarga de orientar/tiltear el modelo; no duplicar aquí.

func _create_name_label() -> void:
	if _name_label != null and is_instance_valid(_name_label):
		return

	_name_label = Label3D.new()
	add_child(_name_label)
	_name_label.name = "NameLabel3D"
	_name_label.position = name_label_offset
	_name_label.modulate = name_label_color
	_name_label.fixed_size = name_label_fixed_size

	if name_label_font != null:
		_name_label.font = name_label_font
	_name_label.font_size = name_label_font_size
	_name_label.no_depth_test = true
	_name_label.outline_size = 2
	_name_label.outline_modulate = Color(0, 0, 0, 0.8)

	# Texto inicial
	if _owner_car != null and is_instance_valid(_owner_car):
		var initial_text: String
		if _owner_car.has_method("get_display_name"):
			initial_text = _owner_car.get_display_name()
		else:
			initial_text = _owner_car.name
		_name_label.text = initial_text
	# Intentar activar billboard si la propiedad existe
	var has_billboard := false
	for p in _name_label.get_property_list():
		if p["name"] == "billboard":
			has_billboard = true
			break
	if has_billboard:
		_name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
