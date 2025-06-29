extends CharacterBody2D
class_name SlimeDeFogo

var _is_dead: bool = false
var _player_ref = null

@export_category("Objects")
@export var _texture: Sprite2D = null
@export var _animation: AnimationPlayer = null


func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("character"):
		_player_ref = _body


func _on_detection_area_body_exited(_body) -> void:
	if _body.is_in_group("character"):
			_player_ref = _body

func _physics_process (_delta: float) -> void:
	if _is_dead:
		return
	_animate()
	if _player_ref != null:
		if _player_ref.is_dead:
			velocity = Vector2.ZERO
			move_and_slide()
			return

		var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
		var _distance: float = global_position.distance_to (_player_ref.global_position)

		if _distance < 20:
			_player_ref.die()

		velocity = _direction * 40
		move_and_slide()

func _animate() -> void:
	if velocity.x > 0:
		_texture.flip_h	= false

	if velocity.x < 0:
		_texture.flip_h	= true

	if velocity !=Vector2.ZERO:
		_animation.play("walk")
		return

	_animation.play("idle")
	
func update_health() -> void:
	_is_dead = true
	_animation.play("death")


func _on_animation_finished(_anim_name: String) -> void:
	queue_free()
