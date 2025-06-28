extends Node2D

@export var slime_scene: PackedScene
@export var spawn_timer: float = 5.0

func _ready():
	spawn_slime()
	start_timer()

func start_timer():
	var timer = Timer.new()
	timer.wait_time = spawn_timer
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "spawn_slime"))
	add_child(timer)
	timer.start()

func spawn_slime():
	var slime = slime_scene.instantiate()
	slime.global_position = self.global_position
	get_parent().add_child(slime)
