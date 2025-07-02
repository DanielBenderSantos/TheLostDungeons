extends CharacterBody2D
class_name Slime

signal slime_died

var _is_dead: bool = false
var _player_ref = null

var _texture: Sprite2D
var _animation: AnimationPlayer

var max_health: int = 5
var current_health: int = 5

# Variáveis de knockback
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_duration: float = 0.2
var knockback_timer: float = 0.0

# Controle de reação ao dano
var is_hit_reacting: bool = false

func _ready():
	_texture = $Texture
	_animation = $Animation
	_animation.play("idle")

	if not _animation.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		_animation.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("character"):
		_player_ref = _body

func _on_detection_area_body_exited(_body) -> void:
	if _body.is_in_group("character"):
		_player_ref = null

func _physics_process(_delta: float) -> void:
	if _is_dead:
		return

	# Se estiver em knockback, ignora outras ações
	if knockback_timer > 0:
		velocity = knockback_velocity
		knockback_timer -= _delta
		move_and_slide()
		# Continua animando mesmo durante o knockback
		_animate()
		return

	_animate()

	if _player_ref != null:
		if _player_ref.is_dead:
			velocity = Vector2.ZERO
			move_and_slide()
			return

		var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
		var _distance: float = global_position.distance_to(_player_ref.global_position)

		if _distance < 20:
			var knockback_direction = (_player_ref.global_position - global_position).normalized()
			_player_ref.apply_knockback(knockback_direction * 150)
			_player_ref.take_damage()

		velocity = _direction * 4
		move_and_slide()

func _animate() -> void:
	# Se estiver reagindo ao dano ou morto, não muda a animação
	if is_hit_reacting or _is_dead:
		return

	if velocity.x > 0:
		_texture.flip_h = false

	if velocity.x < 0:
		_texture.flip_h = true

	if velocity != Vector2.ZERO:
		_animation.play("walk")
		return

	_animation.play("idle")

func take_damage(from_position: Vector2):
	if _is_dead:
		return

	current_health -= 1

	# Ativa a animação de reação ao dano
	is_hit_reacting = true
	_animation.play("hitReaction")
	print("entrou")

	# Aplica knockback no slime
	var knockback_direction = (global_position - from_position).normalized()
	apply_knockback(knockback_direction * 150)

	if current_health <= 0:
		die()

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force
	knockback_timer = knockback_duration

func die() -> void:
	_is_dead = true
	_animation.play("death")

func _on_animation_finished(_anim_name: String) -> void:
	print("saiu2")

	if _anim_name == "death":
		emit_signal("slime_died")
		queue_free()
	elif _anim_name == "hitReaction":
		is_hit_reacting = false
		# Atualiza imediatamente a animação após o hit reaction
		print("saiu")
		_animate()
