extends Control
class_name LevelSelectMenu
## Menú superpuesto para elegir la pista de carrera

signal level_chosen(scene_path: String)

const LEVEL_BLUEPRINTS := [
	{
		"card_name": "OfficeExteriorCard",
		"title": "Exterior Corporativo",
		"subtitle": "Amplias rectas en el rooftop",
		"description": "Trazado urbano abierto con espacio para derrapes largos y tomas panorámicas.",
		"scene_path": "res://scenes/tracks/office_exterior.tscn"
	},
	{
		"card_name": "OfficeInterior1Card",
		"title": "Interior Nivel 1",
		"subtitle": "Pasillos y giros marcados",
		"description": "Circuito técnico entre escritorios y salas de reunión, ideal para precisión.",
		"scene_path": "res://scenes/tracks/office_interior_1.tscn"
	},
	{
		"card_name": "OfficeInterior2Card",
		"title": "Interior Nivel 2",
		"subtitle": "Atajos y doble altura",
		"description": "Combina rampas y curvas ciegas dentro del corazón del edificio.",
		"scene_path": "res://scenes/tracks/office_interior_2.tscn"
	}
]

@onready var _cards_grid: GridContainer = $Panel/MarginContainer/VBoxContainer/LevelsGrid
@onready var _back_button: Button = $Panel/MarginContainer/VBoxContainer/ActionsRow/BackButton


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_cards()
	_back_button.pressed.connect(close)


func open() -> void:
	show()
	_focus_first_card()


func close() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _build_cards() -> void:
	for blueprint in LEVEL_BLUEPRINTS:
		var card_name: String = String(blueprint.get("card_name", ""))
		if card_name.is_empty():
			continue
		if not _cards_grid.has_node(card_name):
			push_warning("No se encontró la tarjeta %s en el LevelSelectMenu" % card_name)
			continue
		var card := _cards_grid.get_node(card_name) as Button
		if card == null:
			continue
		var content := card.get_node("Content") as VBoxContainer
		if content != null:
			var title_label := content.get_node("Title") as Label
			var subtitle_label := content.get_node("Subtitle") as Label
			var desc_label := content.get_node("Description") as Label
			if title_label:
				title_label.text = blueprint.get("title", "Nivel")
			if subtitle_label:
				subtitle_label.text = blueprint.get("subtitle", "")
			if desc_label:
				desc_label.text = blueprint.get("description", "")
		card.tooltip_text = blueprint.get("description", "")
		card.pressed.connect(_on_level_button_pressed.bind(blueprint.get("scene_path", "")))


func _focus_first_card() -> void:
	if _cards_grid.get_child_count() == 0:
		return
	var first_card := _cards_grid.get_child(0) as Control
	if first_card:
		first_card.grab_focus()


func _on_level_button_pressed(scene_path: String) -> void:
	if scene_path.is_empty():
		push_warning("No hay escena configurada para este nivel")
		return
	close()
	level_chosen.emit(scene_path)
