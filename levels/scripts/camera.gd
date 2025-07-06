extends Camera2D

@export var player: Node2D
func _ready():
	if player:
		global_position = player.global_position
func _process(_delta):
	if player:
		var target_position = player.global_position

		target_position.x = clamp(target_position.x, limit_left + get_viewport_rect().size.x / 2, limit_right - get_viewport_rect().size.x / 2)
		target_position.y = clamp(target_position.y, limit_top + get_viewport_rect().size.y / 2, limit_bottom - get_viewport_rect().size.y / 2)

		global_position = target_position
