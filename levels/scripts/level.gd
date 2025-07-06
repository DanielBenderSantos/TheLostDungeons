extends Node2D
class_name Level

const _DIALOG_SCREEN: PackedScene = preload("res://levels/scenes/dialog_screen.tscn")

var _dialog_data: Dictionary = {
	0: { 
		"faceset": "res://levels/assets/subaru.jpg", 
		"dialog": "Olá, seja bem-vindo.", 
		"title": "Narrador",
		"background": "res://levels/assets/img01.png"
	},
	1: { 
		"faceset": "res://levels/assets/subaru.jpg", 
		"dialog": "Como vão?", 
		"title": "Narrador 2",
		"background": "res://levels/assets/img02.png"
	},
	2: { 
		"faceset": "res://levels/assets/subaru.jpg", 
		"dialog": "Boa sorte.", 
		"title": "Narrador",
		"background": "res://levels/assets/img03.png"
	}
}

@export_category("Objects")
@export var _hud: CanvasLayer

var _is_dialog_open: bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_select") and not _is_dialog_open:
		_open_dialog()

func _open_dialog() -> void:
	_is_dialog_open = true
	var _new_dialog: DialogScreen = _DIALOG_SCREEN.instantiate()
	_new_dialog.data = _dialog_data
	
	_new_dialog.connect("dialog_finished", Callable(self, "_on_dialog_finished"))
	_new_dialog.connect("tree_exited", Callable(self, "_on_dialog_closed"))
	
	_hud.add_child(_new_dialog)

func _on_dialog_closed() -> void:
	_is_dialog_open = false

func _on_dialog_finished() -> void:
	# Troca para a nova cena ao terminar o diálogo
	get_tree().change_scene_to_file("res://levels/scenes/fazenda.tscn")
