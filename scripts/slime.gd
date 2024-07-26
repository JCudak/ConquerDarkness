extends CharacterBody2D

const COLLISION_LAYERS = 1
const SPEED_REDUCTION = 3
enum State {IDLE, PURSUING, PREPARING_ATTACK, ATTACKING}

signal healthChanged

@export var speed = 50
@export var burst_speed = 250
@export var dash_speed = 150
@onready var collision_shape_2d = $CollisionShape2D
@onready var animation = $AnimationPlayer

@onready var health: int = 3
@onready var healthBar = $HealthBar

var player: Player = null
var attack_direction = null
var current_state: State = State.IDLE
var has_line_of_sight = false
var on_cooldown = false
var burst_duration = 0.2
var dash_duration = 1
var prepare_duration = 0.4
var cooldown = 2.5
var timer = 0.0
var is_dead = false
var is_hurt = false

func _physics_process(delta):
	die()
	set_line_of_sight()
	updateAnimation(delta)
	updateHealth()

func updateAnimation(delta):
	if is_dead:
		return
	
	if on_cooldown:
		animation.play('default')
		timer -= delta
		if timer <= 0:
			on_cooldown = false
	elif current_state == State.PREPARING_ATTACK:
		animation.play('charge')
		prepare_attack()
		timer -= delta
		if timer <= 0:
			current_state = State.ATTACKING
			timer = dash_duration
	elif current_state == State.ATTACKING:
		animation.play('dash')
		dash_attack(delta)
		timer -= delta
		if timer <= 0:
			on_cooldown = true
			timer = cooldown
			if current_state == State.ATTACKING:
				current_state = State.PREPARING_ATTACK
	elif has_line_of_sight:
			animation.play('walk')
			pursue_player(delta)
	else:
		animation.play("default")

func pursue_player(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction[0] * speed
	velocity.y = direction[1] * speed 
	move_and_slide()

func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body
		current_state = State.PURSUING

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		current_state = State.IDLE
		has_line_of_sight = false

func _on_attack_area_body_entered(body):
	if body.name == "Player":
		current_state = State.PREPARING_ATTACK
		timer = prepare_duration

func _on_attack_area_body_exited(body):
	if body.name == "Player":
		current_state = State.PURSUING

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
		
		#effects.play("RESET")
		#animation.play("death")
		
		#await get_tree().create_timer(1).timeout
		
		queue_free()

func _on_hurt_box_area_entered(area):
	if area.name == "SwordDamageArea": # Add more names when more weapons for player
		is_hurt = true
		health -= 1
		#effects.play("hurtBlink")
		
		#animation.play("damaged")
		
		#await get_tree().create_timer(0.6).timeout
		#effects.play("RESET")
		
		is_hurt = false
		healthChanged.emit(health)

func updateHealth():
	healthBar.max_value = 3
	healthBar.value = health
	
	print_debug(healthBar.value)
