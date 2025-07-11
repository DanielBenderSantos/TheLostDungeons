extends CharacterBody2D
class_name PlantAssassin

signal plant_assassin_died

# --- Referências a nós -------------------------------------------------------
@onready var _texture: Sprite2D         = $Texture        # sprite principal
@onready var _animation: AnimationPlayer = $Animation     # animações

# --- Constantes de comportamento --------------------------------------------
const MOVE_SPEED     : float = 180.0    # velocidade de corrida (px/s)
const STOP_DISTANCE  : float = 20.0     # distância mínima antes de parar para atacar

# --- Atributos de combate ----------------------------------------------------
var max_health      : int   = 3
var current_health  : int   = 3
var attack_cooldown : float = 0.8       # intervalo entre mordidas
var attack_timer    : float = 0.0

# --- Controle de hit‑stun/knockback -----------------------------------------
var knockback_velocity : Vector2 = Vector2.ZERO
var knockback_duration : float   = 0.20
var knockback_timer    : float   = 0.0
var is_hit_reacting    : bool    = false

# --- Estado ------------------------------------------------------------------
var _player_ref : Node = null
var _is_dead    : bool = false

# -----------------------------------------------------------------------------    
func _ready() -> void:
	_animation.play("idle")
	
	if not _animation.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		_animation.connect("animation_finished", Callable(self, "_on_animation_finished"))

# -----------------------------------------------------------------------------    
func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	
	# Aplica knockback se necessário
	if knockback_timer > 0.0:
		velocity         = knockback_velocity
		knockback_timer -= delta
		move_and_slide()
		_animate()
		return

	# Contagem do cooldown de ataque
	if attack_timer > 0.0:
		attack_timer -= delta

	# Movimento em direção ao jogador, se houver alvo
	if _player_ref:
		if _player_ref.is_dead:
			velocity = Vector2.ZERO
		else:
			var dir      : Vector2 = global_position.direction_to(_player_ref.global_position)
			var distance : float   = global_position.distance_to(_player_ref.global_position)
			
			if distance > STOP_DISTANCE:
				velocity = dir * MOVE_SPEED
			else:
				velocity = Vector2.ZERO      # já está perto o suficiente para atacar
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	_animate()

	# Verifica colisões para aplicar dano/empurrão
	for i in range(get_slide_collision_count()):
		var c = get_slide_collision(i)
		if c.get_collider().is_in_group("character") and attack_timer <= 0.0:
			var knock_dir = (c.get_collider().global_position - global_position).normalized()
			c.get_collider().apply_knockback(knock_dir * 180)
			c.get_collider().take_damage()
			attack_timer = attack_cooldown

# -----------------------------------------------------------------------------    
func _on_detection_area_body_entered(body) -> void:
	if body.is_in_group("character"):
		_player_ref = body

func _on_detection_area_body_exited(body) -> void:
	if body == _player_ref:
		_player_ref = null

# -----------------------------------------------------------------------------    
func take_damage(from_position: Vector2) -> void:
	if _is_dead:
		return
	
	current_health -= 1
	is_hit_reacting = true
	_animation.play("hitReaction")
	
	var knock_dir = (global_position - from_position).normalized()
	apply_knockback(knock_dir * 180)

	if current_health <= 0:
		die()

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force
	knockback_timer    = knockback_duration

func die() -> void:
	_is_dead = true
	_animation.play("death")

func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"death":
			emit_signal("plant_assassin_died")
			queue_free()
		"hitReaction":
			is_hit_reacting = false
			_animate()

# -----------------------------------------------------------------------------    
func _animate() -> void:
	if is_hit_reacting or _is_dead:
		return

	# Espelhamento do sprite
	if velocity.x > 0:
		_texture.flip_h = false
	elif velocity.x < 0:
		_texture.flip_h = true

	# Escolha de animação
	if velocity.length() > 0:
		_animation.play("walk")
	else:
		_animation.play("idle")
