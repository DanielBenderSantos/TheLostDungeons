extends TextureProgressBar

@export var player = Node2D

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	max_value = player.max_health
	value = player.current_health
