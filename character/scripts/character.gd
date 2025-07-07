extends CharacterBody2D
class_name Character

var _state_machine
var is_dead: bool = false
var _is_attacking: bool = false

@export_category("Variables")
@export var _move_speed: float = 64.0
@export var _friction: float = 0.2
@export var _acceleration: float = 0.2	
@export var max_health: int = 50
var current_health: int = 10

@export var max_stamina: float = 100.0
var current_stamina: float = 100.0
@export var stamina_consumption_rate: float = 30.0
@export var stamina_recovery_rate: float = 20.0
@export var exhaustion_recovery_delay: float = 2.0  # Tempo de espera extra ao ficar cansado

var is_exhausted: bool = false  # Travar corrida quando stamina chegar a zero
var exhaustion_timer: float = 0.0

@export_category("Objects")
@export var _attack_timer: Timer = null
@export var _animation_tree: AnimationTree = null

# Variáveis de knockback
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_duration: float = 0.2
var knockback_timer: float = 0.0

# Controle de velocidade dinâmica
var _base_speed: float = 64.0
var _current_speed: float = 64.0

# Controle da recuperação de vida
var _is_healing: bool = false
var time_since_last_hit: float = 0.0
var heal_cooldown: float = 10.0  # Tempo sem tomar dano para iniciar a cura

func _ready() -> void:
	current_health = max_health
	current_stamina = max_stamina
	_base_speed = _move_speed
	_current_speed = _move_speed
	_animation_tree.active = true
	_state_machine = _animation_tree["parameters/playback"]

func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	# Controle de stamina e corrida com bloqueio e cansaço
	if is_exhausted:
		_current_speed = _base_speed
		exhaustion_timer -= _delta
		if exhaustion_timer <= 0.0:
			is_exhausted = false  # Libera corrida novamente
	else:
		if Input.is_action_pressed("correr") and current_stamina > 0 and direction != Vector2.ZERO:
			_current_speed = _base_speed * 2
			current_stamina -= stamina_consumption_rate * _delta
			if current_stamina <= 0:
				current_stamina = 0
				is_exhausted = true
				exhaustion_timer = exhaustion_recovery_delay
		else:
			_current_speed = _base_speed
			current_stamina += stamina_recovery_rate * _delta

	current_stamina = clamp(current_stamina, 0, max_stamina)

	# Atualiza tempo desde o último hit
	time_since_last_hit += _delta

	# Se estiver em knockback, ignora outras ações
	if knockback_timer > 0:
		velocity = knockback_velocity
		knockback_timer -= _delta
		move_and_slide()
		return

	# Inicia recuperação de vida somente após 10 segundos sem dano
	if current_health < max_health and not _is_healing and time_since_last_hit >= heal_cooldown:
		_start_health_recovery()

	_move()
	_attack()
	_animate()
	move_and_slide()

func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if _direction != Vector2.ZERO:
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		_animation_tree["parameters/attack/blend_position"] = _direction

		velocity.x = lerp(velocity.x, _direction.normalized().x * _current_speed, _acceleration)
		velocity.y = lerp(velocity.y, _direction.normalized().y * _current_speed, _acceleration)
		return

	velocity.x = lerp(velocity.x, _direction.normalized().x * _current_speed, _friction)
	velocity.y = lerp(velocity.y, _direction.normalized().y * _current_speed, _friction)

func _attack() -> void:
	if Input.is_action_just_pressed("attack") and not _is_attacking:
		set_physics_process(false)
		_attack_timer.start()
		_is_attacking = true	

func _animate() -> void:
	if _is_attacking:
		_state_machine.travel("attack")
		return	

	if velocity.length() > 5:
		_state_machine.travel("walk")
		return
	_state_machine.travel("idle")

func _on_attack_timer_timeout() -> void:
	_is_attacking = false
	set_physics_process(true)

func _on_attack_area_body_entered(_body) -> void:
	if _body.is_in_group("enemy"):
		_body.take_damage(global_position)

func take_damage(damage: int) -> void:
	current_health -= damage
	time_since_last_hit = 0.0  # Reinicia o tempo ao levar dano
	if current_health <= 0:
		die()

func die() -> void:
	is_dead = true
	_state_machine.travel("death")		
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force
	knockback_timer = knockback_duration

func _start_health_recovery() -> void:
	_is_healing = true
	await _recover_health()
	_is_healing = false

func _recover_health() -> void:
	while current_health < max_health:
		# Se tomar dano durante a recuperação, cancela
		if time_since_last_hit < heal_cooldown:
			break
		await get_tree().create_timer(1.0).timeout
		current_health += 1
		current_health = min(current_health, max_health)
