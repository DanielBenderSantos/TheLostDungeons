extends Node2D

@export var slime_scene: PackedScene
@export var spawn_timer: float = 1.0

var current_slime = null
var timer = null

func _ready():
	spawn_slime()

func spawn_slime():
	# Cria o slime
	current_slime = slime_scene.instantiate()
	current_slime.global_position = self.global_position
	get_parent().add_child.call_deferred(current_slime)

	# Conecta o sinal de morte do slime
	current_slime.connect("slime_died", Callable(self, "_on_slime_died"))

func _on_slime_died():
	current_slime = null

	# Cria e inicia o timer para o próximo slime
	if timer == null:
		timer = Timer.new()
		add_child(timer)

	timer.wait_time = spawn_timer
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "spawn_slime"))
	timer.start()
