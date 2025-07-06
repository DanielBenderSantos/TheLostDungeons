extends Node2D
class_name Level

const _DIALOG_SCREEN: PackedScene = preload("res://levels/scenes/dialog_screen.tscn")

var _dialog_data: Dictionary = {
	0: { "faceset": "res://levels/assets/criador.png", "dialog": "Em um mundo repleto de aventureiros e tesouros, nasceu Anora — um jovem de espírito inquieto e sede insaciável por descobertas.", "title": "Narrador" },
		1: { "faceset": "res://levels/assets/criador.png", "dialog": "Desde criança, ouvia lendas sobre as enigmáticas 'Masmorras Perdidas' — locais que ninguém jamais conseguiu explorar e voltar para contar.", "title": "Narrador" },
	2: { "faceset": "res://levels/assets/criador.png", "dialog": "Dizem que existem cinco dessas masmorras espalhadas pelo mundo, cada uma cercada de mistérios e perigos.", "title": "Narrador" },
	3: { "faceset": "res://levels/assets/criador.png", "dialog": "Alguns acreditam que quem as adentra é transportado para outra dimensão. Outros falam de tesouros capazes de realizar qualquer desejo.", "title": "Narrador" },
	4: { "faceset": "res://levels/assets/criador.png", "dialog": "Há ainda quem afirme que tudo não passa de armadilhas mortais, repletas de gases venenosos e ilusões letais.", "title": "Narrador" },
	5: { "faceset": "res://levels/assets/criador.png", "dialog": "O que é certo é que ninguém nunca voltou. Mas, ainda assim, a curiosidade continua a atrair novos aventureiros para uma provável morte certa.", "title": "Narrador" },
	6: { "faceset": "res://levels/assets/criador.png", "dialog": "Você, no entanto, é diferente. Não pretende se jogar de cabeça sem preparo.", "title": "Narrador" },
	7: { "faceset": "res://levels/assets/criador.png", "dialog": "Vai construir armas, forjar escudos, criar equipamentos, viver uma vida dedicada a juntar ouro e materiais — tudo para estar pronto.", "title": "Narrador" },
	8: { "faceset": "res://levels/assets/criador.png", "dialog": "Só então você ousará encarar as Masmorras Perdidas. Afinal, você ama a aventura... mas não é tolo.", "title": "Narrador" }
}

var _narration_audio: Dictionary = {
	0: preload("res://levels/assets/audio/narration_0.mp3"),
	1: preload("res://levels/assets/audio/narration_1.mp3"),
	2: preload("res://levels/assets/audio/narration_2.mp3"),
	3: preload("res://levels/assets/audio/narration_3.mp3"),
	4: preload("res://levels/assets/audio/narration_4.mp3"),
	5: preload("res://levels/assets/audio/narration_5.mp3"),
	6: preload("res://levels/assets/audio/narration_6.mp3"),
	7: preload("res://levels/assets/audio/narration_7.mp3"),
	8: preload("res://levels/assets/audio/narration_8.mp3")
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
	_new_dialog.audio = _narration_audio
	_new_dialog.setup()

	_new_dialog.connect("dialog_finished", Callable(self, "_on_dialog_finished"))
	_new_dialog.connect("tree_exited", Callable(self, "_on_dialog_closed"))

	_hud.add_child(_new_dialog)

func _on_dialog_closed() -> void:
	_is_dialog_open = false

func _on_dialog_finished() -> void:
	get_tree().change_scene_to_file("res://levels/scenes/fazenda.tscn")
