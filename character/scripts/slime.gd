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

# Controle de tempo entre ataques
var attack_cooldown: float = 0.5
var attack_timer: float = 0.0

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

	if knockback_timer > 0:
		velocity = knockback_velocity
		knockback_timer -= _delta
		move_and_slide()
		_animate()
		return

	_animate()

	# Atualiza cooldown de ataque
	if attack_timer > 0:
		attack_timer -= _delta

	if _player_ref != null:
		if _player_ref.is_dead:
			velocity = Vector2.ZERO
			move_and_slide()
			return

		var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
		velocity = _direction * 40

		move_and_slide()

		# Verifica colisões físicas
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("character") and attack_timer <= 0:
				var knockback_direction = (collision.get_collider().global_position - global_position).normalized()
				collision.get_collider().apply_knockback(knockback_direction * 150)
				collision.get_collider().take_damage()
				attack_timer = attack_cooldown  # Reseta o cooldown de ataque

func _animate() -> void:
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

	is_hit_reacting = true
	_animation.play("hitReaction")
	print("entrou")

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
		print("saiu")
		_animate()


func _on_slime_died() -> void:
	pass # Replace with function body.
