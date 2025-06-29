extends Node2D

@export var slime_scene: PackedScene
@export var spawn_timer: float = 1.0

var current_slime = null
var timer = null

func _ready():
	spawn_slime()
	_on_slime_died()
	
func spawn_slime():
	# Cria o slime
	current_slime = slime_scene.instantiate()
	current_slime.global_position = self.global_position
	get_parent().add_child(current_slime)

	# Conecta o sinal de morte do slime
	current_slime.connect("slime_died", Callable(self, "_on_slime_died"))

func _on_slime_died():
	current_slime = null

	# Cria e inicia o timer para o próximo slime
	timer = Timer.new()
	timer.wait_time = spawn_timer
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "spawn_slime"))
	add_child(timer)
	timer.start()
