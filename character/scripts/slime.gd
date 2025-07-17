extends CharacterBody2D
class_name Slime

signal slime_died

var _is_dead: bool = false
var _is_attacking: bool = false
var _player_ref = null
var _attack_target = null

var _texture: Sprite2D
var _animation: AnimationPlayer
var _attack_area: Area2D = null

var max_health: int = 5
var current_health: int = 5

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_duration: float = 0.2
var knockback_timer: float = 0.0

# Controle de dano e ataque
var is_hit_reacting: bool = false
var attack_cooldown: float = 0.5
var attack_timer: float = 0.0
@export var attack_damage: int = 10

# Posição original da área de ataque
var _attack_area_origin_x: float = 0.0

func _ready():
	_texture = $Texture
	_animation = $Animation
	_attack_area = get_node_or_null("AttackArea")

	_animation.play("idle")

	if _attack_area:
		_attack_area_origin_x = _attack_area.position.x
	else:
		push_error("AttackArea não encontrado no nó atual!")

	if not _animation.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		_animation.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("character"):
		_player_ref = _body

func _on_detection_area_body_exited(_body) -> void:
	if _body.is_in_group("character"):
		_player_ref = null
		velocity = Vector2.ZERO
		_animate()

func _physics_process(_delta: float) -> void:
	if _is_dead:
		return

	if knockback_timer > 0:
		velocity = knockback_velocity
		knockback_timer -= _delta
		move_and_slide()
		_animate()
		return

	if attack_timer > 0:
		attack_timer -= _delta

	if _is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if _player_ref != null:
		if _player_ref.is_dead:
			velocity = Vector2.ZERO
			move_and_slide()
			return

		var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
		velocity = _direction * 40

		move_and_slide()

		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("character") and attack_timer <= 0:
				_start_attack(collision.get_collider())
				return

	_animate()

func _start_attack(target):
	if _is_dead or is_hit_reacting:
		return

	_is_attacking = true
	_attack_target = target
	_animation.play("attack")
	velocity = Vector2.ZERO

func _animate() -> void:
	if is_hit_reacting or _is_dead or _is_attacking:
		return

	if velocity.x > 0:
		_texture.flip_h = false
		if _attack_area:
			_attack_area.position.x = _attack_area_origin_x
	elif velocity.x < 0:
		_texture.flip_h = true
		if _attack_area:
			_attack_area.position.x = -_attack_area_origin_x

	if velocity != Vector2.ZERO:
		_animation.play("walk")
	else:
		_animation.play("idle")

func take_damage(from_position: Vector2):
	if _is_dead or is_hit_reacting:
		return

	current_health -= 1
	is_hit_reacting = true
	_animation.play("hitReaction")

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

func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"death":
			emit_signal("slime_died")
			queue_free()

		"hitReaction":
			is_hit_reacting = false
			if _player_ref != null and not _player_ref.is_dead:
				_start_attack(_player_ref)
			else:
				_animation.play("idle")

		"attack":
			if _attack_target and is_instance_valid(_attack_target) and _attack_area:
				var bodies = _attack_area.get_overlapping_bodies()
				if _attack_target in bodies:
					var knockback_direction = (_attack_target.global_position - global_position).normalized()
					_attack_target.apply_knockback(knockback_direction * 150)
					_attack_target.take_damage(attack_damage)
					attack_timer = attack_cooldown

			_attack_target = null
			_is_attacking = false
			_animate()

func _on_slime_died() -> void:
	pass
