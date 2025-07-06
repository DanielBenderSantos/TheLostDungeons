extends Area2D
class_name DoorComponent

var _player_ref: Character = null

@export_category("Variables")
@export var _teleport_position: Vector2

@export var new_limit_left: int = 0
@export var new_limit_right: int = 0
@export var new_limit_top: int = 0
@export var new_limit_bottom: int = 0

@export_category("Objects")
@export var _animation: AnimationPlayer = null

func _on_body_entered(_body) -> void:
	if _body is Character:
		_player_ref = _body
		_animation.play("open")

func _on_animation_finished(_anim_name: String) -> void:
	if _anim_name == "open":
		_player_ref.global_position = _teleport_position

		# Atualiza os limites da câmera PRIMEIRO
		var camera = get_tree().get_first_node_in_group("camera")
		if camera:
			camera.limit_left = new_limit_left
			camera.limit_right = new_limit_right
			camera.limit_top = new_limit_top
			camera.limit_bottom = new_limit_bottom

			# Agora sim pode centralizar a câmera no player
			camera.global_position = _player_ref.global_position

		_animation.play("close")
