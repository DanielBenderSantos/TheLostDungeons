extends Node2D
class_name Level

const _DIALOG_SCREEN: PackedScene = preload("res://levels/scenes/dialog_screen.tscn")

var _dialog_data: Dictionary = {
	0: { 
		"faceset": "res://levels/assets/subaru.jpg", 
		"dialog": "Em um mundo repleto de aventureiros e tesouros, nasceu Anora — um jovem de espírito inquieto e sede insaciável por descobertas.",
		"title": "Narrador"
	},
	1: { 
		"faceset": "res://levels/assets/subaru.jpg", 
		"dialog": "Desde criança, ouvia lendas sobre as enigmáticas 'Masmorras Perdidas' — locais que ninguém jamais conseguiu explorar e voltar para contar.",
		"title": "Narrador"
	},
	2: { 
		"faceset": "res://levels/assets/subaru.jpg", 
		"dialog": "Dizem que existem cinco dessas masmorras espalhadas pelo mundo, cada uma cercada de mistérios e perigos.",
		"title": "Narrador"
	},
	3: { 
		"faceset": "res://levels/assets/subaru.jpg", 
		"dialog": "Alguns acreditam que quem as adentra é transportado para outra dimensão. Outros falam de tesouros capazes de realizar qualquer desejo.",
		"title": "Narrador"
	},
	4: { 
		"faceset": "res://levels/assets/subaru.jpg", 
		"dialog": "Há ainda quem afirme que tudo não passa de armadilhas mortais, repletas de gases venenosos e ilusões letais.",
		"title": "Narrador"
	},
	5: { 
		"faceset": "res://levels/assets/subaru.jpg", 
		"dialog": "O que é certo é que ninguém nunca voltou. Mas, ainda assim, a curiosidade continua a atrair novos aventureiros para uma provável morte certa.",
		"title": "Narrador"
	},
	6: { 
		"faceset": "res://levels/assets/subaru.jpg", 
		"dialog": "Você, no entanto, é diferente. Não pretende se jogar de cabeça sem preparo.",
		"title": "Narrador"
	},
	7: { 
		"faceset": "res://levels/assets/subaru.jpg", 
		"dialog": "Vai construir armas, forjar escudos, criar equipamentos, viver uma vida dedicada a juntar ouro e materiais — tudo para estar pronto.",
		"title": "Narrador"
	},
	8: { 
		"faceset": "res://levels/assets/subaru.jpg", 
		"dialog": "Só então você ousará encarar as Masmorras Perdidas. Afinal, você ama a aventura... mas não é tolo.",
		"title": "Narrador"
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
	_new_dialog.setup()

	_new_dialog.connect("dialog_finished", Callable(self, "_on_dialog_finished"))
	_new_dialog.connect("tree_exited", Callable(self, "_on_dialog_closed"))
	
	_hud.add_child(_new_dialog)

func _on_dialog_closed() -> void:
	_is_dialog_open = false

func _on_dialog_finished() -> void:
	get_tree().change_scene_to_file("res://levels/scenes/fazenda.tscn")
