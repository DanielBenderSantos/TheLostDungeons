extends Control
class_name DialogScreen

signal dialog_finished

@export_category("Objects")
@export var _faceset: TextureRect
@export var _name: Label
@export var _dialog: RichTextLabel

var data: Dictionary = {}
var _id: int = 0
var _step: float = 0.05

var _is_skipping: bool = false

func _ready() -> void:
	_initialize_dialog()

func _process(_delta: float) -> void:
	# Controla a velocidade de escrita quando segurar o botão
	if Input.is_action_pressed("ui_accept"):
		_is_skipping = true
	else:
		_is_skipping = false

	_step = 0.01 if _is_skipping else 0.05

	# Avança o texto ou o diálogo
	if Input.is_action_just_pressed("ui_accept"):
		if _dialog.visible_ratio < 1:
			# Mostra tudo de uma vez se ainda estiver digitando
			_dialog.visible_characters = _dialog.text.length()
			return
		
		# Avança para o próximo diálogo
		_id += 1
		if _id == data.size():
			emit_signal("dialog_finished")
			queue_free()
			return

		_initialize_dialog()

func _initialize_dialog() -> void:
	if not data.has(_id):
		print("ID de diálogo inválido: ", _id)
		queue_free()
		return

	var dialog_entry = data[_id]
	_name.text = dialog_entry.get("title", "Sem Título")
	_dialog.text = dialog_entry.get("dialog", "...")
	_faceset.texture = load(dialog_entry.get("faceset", "res://default.png"))

	_dialog.visible_characters = 0

	while _dialog.visible_ratio < 1:
		await get_tree().create_timer(_step).timeout
		_dialog.visible_characters += 1
