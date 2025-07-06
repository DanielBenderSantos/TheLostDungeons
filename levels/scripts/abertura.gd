extends Node2D

var cutscene_images = [
	"res://levels/assets/img01.png",
	"res://levels/assets/img02.png",
	"res://levels/assets/img03.png"
]

var cutscene_texts = [
	"Há muito tempo, um reino caiu em trevas...",
	"Um herói foi profetizado para restaurar a paz...",
	"E é aqui que sua jornada começa..."
]

var current_index = 0
var typing_speed = 0.05 # Velocidade de digitação
var current_char_index = 0
var is_typing = false

@onready var sprite = $Sprite2D
@onready var label = $Label
@onready var typing_timer = Timer.new()

func _ready():
	var viewport_size = get_viewport_rect().size

	# Configurar o label responsivo
	label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	label.position.y = viewport_size.y * 0.1
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 8)

	# Ativar quebra automática de texto
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.size.x = viewport_size.x * 0.8 # Limitar largura do label

	# Preparar o timer de digitação
	typing_timer.wait_time = typing_speed
	typing_timer.one_shot = false
	typing_timer.timeout.connect(_on_typing_timer_timeout)
	add_child(typing_timer)

	# Mostrar a primeira cena
	mostrar_cena()

func mostrar_cena():
	var texture = load(cutscene_images[current_index])
	sprite.texture = texture
	sprite.global_position = get_viewport_rect().size / 2

	# Escala proporcional
	var viewport_size = get_viewport_rect().size
	var texture_size = texture.get_size()
	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	var final_scale = min(scale_x, scale_y)
	sprite.scale = Vector2(final_scale, final_scale)

	# Iniciar digitação do texto
	label.text = ""
	current_char_index = 0
	is_typing = true
	typing_timer.start()

func _on_typing_timer_timeout():
	if current_char_index < cutscene_texts[current_index].length():
		label.text += cutscene_texts[current_index][current_char_index]
		current_char_index += 1
	else:
		is_typing = false
		typing_timer.stop()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			# Se estiver digitando, mostrar o texto completo imediatamente
			label.text = cutscene_texts[current_index]
			is_typing = false
			typing_timer.stop()
		else:
			# Trocar imagem
			current_index += 1
			if current_index < cutscene_images.size():
				mostrar_cena()
			else:
				get_tree().change_scene_to_file("res://levels/scenes/fazenda.tscn")
