class_name Enemy extends CharacterBody2D

const COLLISION_LAYERS = 1
const SPEED_REDUCTION = 3
enum State {IDLE, PURSUING, PREPARING_ATTACK, ATTACKING}

signal healthChanged

@export var speed = 50
@export var max_speed = 50
@export var dash_speed = 150
@export var damage = 10
@onready var collision_shape_2d = $CollisionShape2D
@onready var animation = $AnimationPlayer
@onready var deathTimer = $Timers/DeathTimer
@onready var hurtTimer = $Timers/HurtTimer
@onready var cooldownTimer = $Timers/CooldownTimer
@onready var prepareAttackTimer = $Timers/PrepareAttackTimer
@onready var attackTimer = $Timers/AttackTimer
@onready var slow_effect_timer = $Timers/SlowEffectTimer
@onready var slow_status_icon = $hurtBox/hurtBoxCollisionShape2D/SlowStatusIcon
@onready var enemy_dash = $SoundEffects/EnemyDash
@onready var enemy_walk = $SoundEffects/EnemyWalk

signal spawn_collectable

@export var health: int = 15
@onready var healthBar = $HealthBar
@onready var effects = $Effects

var player: Player = null
var attack_direction = null
var current_state: State = State.IDLE
var has_line_of_sight: bool = false
var on_cooldown: bool = false
@export var dash_duration: float = 1.0
@export var prepare_duration: float = 0.4
@export var cooldown:float = 2.0
var is_dead: bool = false
var is_hurt: bool = false
var walk_sound: bool = false
var is_in_attack_area: bool = false
var is_in_detection_area: bool = false
var slow_status_time: float = 4.0

func _ready():
	
	slow_status_icon.visible = false
	healthBar.max_value = health
	cooldownTimer.timeout.connect(_on_cooldown_timer_timeout)
	prepareAttackTimer.timeout.connect(_on_prepare_attack_timer_timeout)
	attackTimer.timeout.connect(_on_attack_timer_timeout)
	slow_effect_timer.timeout.connect(_on_slow_effect_timer_timeout)

func _physics_process(delta):
	die()
	set_line_of_sight()
	updateAnimation(delta)
	updateHealth()

func updateAnimation(delta):
	if is_dead or is_hurt:
		return
	
	if on_cooldown:
		animation.play('default')
	elif current_state == State.PREPARING_ATTACK:
		animation.play('charge')
	elif current_state == State.ATTACKING:
		animation.play('dash')
		dash_attack(delta)
	elif has_line_of_sight:
		animation.play('walk')
		pursue_player(delta)
	else:
		animation.play("default")

func _on_cooldown_timer_timeout():
	cooldownTimer.stop()
	on_cooldown = false
	_reset_state()

func _on_prepare_attack_timer_timeout():
	prepareAttackTimer.stop()
	current_state = State.ATTACKING
	attackTimer.wait_time = dash_duration
	attackTimer.start()
	
	AudioController.play_sfx($SoundEffects/EnemyDash.stream, $SoundEffects, -30.0, 10.0)

func _on_attack_timer_timeout():
	attackTimer.stop()
	on_cooldown = true
	cooldownTimer.wait_time = cooldown
	cooldownTimer.start()

func _on_slow_effect_timer_timeout():
	slow_status_icon.visible = false
	speed = max_speed

func _reset_state():
	if is_in_attack_area:
		current_state = State.PREPARING_ATTACK
		prepare_attack()
		prepareAttackTimer.wait_time = prepare_duration
		prepareAttackTimer.start()
	elif is_in_detection_area:
		current_state = State.PURSUING
	else:
		current_state = State.IDLE

func pursue_player(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction[0] * speed
	velocity.y = direction[1] * speed 
	
	if !walk_sound:
		play_walk_sound()
	
	move_and_slide()

func play_walk_sound():
	walk_sound = true
	AudioController.play_sfx($SoundEffects/EnemyWalk.stream, $SoundEffects, -30.0, 5.0)
	await get_tree().create_timer(0.6).timeout
	walk_sound = false

func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body
		is_in_detection_area = true
		if current_state == State.IDLE:
			current_state = State.PURSUING

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		has_line_of_sight = false
		is_in_detection_area = false
		if current_state == State.PURSUING:
			current_state = State.IDLE

func _on_attack_area_body_entered(body):
	if body.name == "Player":
		if current_state == State.PURSUING:
			current_state = State.PREPARING_ATTACK
			prepare_attack()
			prepareAttackTimer.wait_time = prepare_duration
			prepareAttackTimer.start()
		is_in_attack_area = true

func _on_attack_area_body_exited(body):
	if body.name == "Player":
		is_in_attack_area = false

func prepare_attack():
	if player and has_line_of_sight:
		velocity = (player.global_position - global_position).normalized() * dash_speed

func dash_attack(delta):
	if player:
		velocity.x = move_toward(velocity.x, 0, SPEED_REDUCTION)
		velocity.y = move_toward(velocity.y, 0, SPEED_REDUCTION)
		var move_vector = velocity * delta
		var collision = move_and_collide(move_vector)
		if collision:
			velocity = velocity.bounce(collision.get_normal())

func set_line_of_sight():
	if player and current_state == State.PURSUING:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
		query.exclude = [self]
		query.collision_mask = COLLISION_LAYERS
		var result = space_state.intersect_ray(query)
		if result and result.collider.name == "Player":
			has_line_of_sight = true
		else:
			has_line_of_sight = false

func die():
	if health <= 0 and not is_dead:
		is_dead = true
		
		velocity.x = 0
		velocity.y = 0
		
		effects.play("RESET")
		animation.play("death")
		
		deathTimer.start()
		await deathTimer.timeout
		
		emit_signal("spawn_collectable", position)
		queue_free()

func _on_hurt_box_area_entered(area):
	if is_hurt:
		return
	
	if area.name == "SwordDamageArea": # Add more names when more weapons for player
		is_hurt = true
		if player.slow_power != 0:
			slow_status_icon.visible = true
			speed = max_speed - player.slow_power
			slow_effect_timer.wait_time = slow_status_time
			slow_effect_timer.start()
		effects.play("hurtBlink")
		
		emit_signal("healthChanged")
		animation.play("damaged")
		hurtTimer.start()
		
		await hurtTimer.timeout
		effects.play("RESET")

func updateHealth():
	healthBar.value = health

func _on_health_changed():
	health -= player.damage
	await get_tree().create_timer(0.6).timeout # Offset to not get multiple hits at once
	is_hurt = false
