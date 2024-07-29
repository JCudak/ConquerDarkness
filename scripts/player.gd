extends CharacterBody2D

class_name Player

signal healthChanged
signal shieldChanged

const SPEED_REDUCTION = 12
@export var speed = 100.0
@onready var sprite_2d = $Sprites/Sprite2D
@onready var sword = $Sprites/Sword
@onready var sprites = $Sprites
@onready var animation = $AnimationPlayer
@export var slotsContainer: Node

@export var maxHealth = 10
@export var maxShield = 5
@export var damage = 5
@onready var currentHealth: int = maxHealth
@onready var currentShield: int = 0
@onready var deathTimer = $Timers/DeathTimer
@onready var hurtTimer = $Timers/HurtTimer
@onready var speed_up_timer = $Timers/SpeedUpTimer
@onready var damage_up_timer = $Timers/DamageUpTimer
@onready var effects = $Effects
@onready var aura = $Sprites/Aura
@onready var shield = $Sprites/Shield

@export var linked_position_node: Node2D

var is_dead = false
var is_hurt = false
var is_attacking = false
var current_immunities = 0

var attackDirection: Vector2
var targetPosition: Vector2

func _ready():
	aura.visible = false
	shield.visible = false
	var containers = slotsContainer.get_children()
	
	for container in containers:
		if container is SlotsContainerGui:
			container.use_item.connect(use_item)
			
	effects.play("RESET")

func _process(delta):
	if linked_position_node != null:
		linked_position_node.position = self.position

func _physics_process(delta):
	die()
	
	if is_dead:
		return
	
	update_animation()
	move_and_slide()
	attack_animation()

func update_animation():
	var directionX = Input.get_axis("left", "right")
	var directionY = Input.get_axis("up", "down")
	
	if directionX:
		velocity.x = directionX * speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED_REDUCTION)
	if directionY:
		velocity.y = directionY * speed
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED_REDUCTION)
	
	if is_attacking:
		return
	
	if velocity.x < 0:
		sprites.scale.x = -abs(sprites.scale.x)
	elif velocity.x > 0:
		sprites.scale.x = abs(sprites.scale.x)
	else:
		pass
	
	if is_hurt:
		return
	
	if (absf(velocity.x) > 1.0 || absf(velocity.y) > 1.0):
		animation.play("running")
	else:
		animation.play("default")

func die():
	if currentHealth <= 0 and not is_dead:
		is_dead = true
		
		velocity.x = 0
		velocity.y = 0
		
		effects.play("RESET")
		animation.play("death")
		
		deathTimer.start()
		await deathTimer.timeout
		
		get_tree().change_scene_to_file("res://assets/scenes/death_menu.tscn")

func _on_hurt_box_area_entered(area):
	if is_hurt:
		return
	
	if area.name == "hitBox": # Add more names when new enemies
		if current_immunities > 0:
			current_immunities -= 1
			if current_immunities == 0:
				shield.visible = false
				pass
		else:
			is_hurt = true
			if currentShield > 0:
				currentShield -= 1
				emit_signal("shieldChanged", currentShield)
			else:
				currentHealth -= 1
				emit_signal("healthChanged", currentHealth)
			
			effects.play("hurtBlink")
			
			animation.play("damaged")
		
		hurtTimer.start()
		await hurtTimer.timeout
		effects.play("RESET")
		

func attack_animation():
	if Input.is_action_just_pressed("attack"):
		if is_attacking: 
			return
		
		is_attacking = true
		targetPosition = get_viewport().get_mouse_position()
		
		attackDirection = (targetPosition - global_position).normalized()

		
		if attackDirection[0] > 0 and -attackDirection[1] > 0:
			sprites.scale.x = abs(sprites.scale.x)
			animation.play("attackUp")
		elif attackDirection[0] < 0 and -attackDirection[1] > 0:
			sprites.scale.x = -abs(sprites.scale.x)
			animation.play("attackUp") 
		elif attackDirection[0] < 0 and -attackDirection[1] < 0:
			sprites.scale.x = -abs(sprites.scale.x)
			animation.play("attackDown") 
		else:
			sprites.scale.x = abs(sprites.scale.x)
			animation.play("attackDown") 
		
		await get_tree().create_timer(0.6).timeout
		
		is_attacking = false

func use_item(item: InventoryItem):
	item.use(self)

func _on_health_changed(currentHealth):
	await get_tree().create_timer(1).timeout # Offset to not get multiple hits at once
	is_hurt = false

func add_health(health_increase):
	currentHealth = min(currentHealth + health_increase, maxHealth)
	emit_signal("healthChanged", currentHealth)
	
func add_shield(shield_increase):
	currentShield = min(currentShield + shield_increase, maxShield)
	emit_signal("shieldChanged", currentShield)
	
func add_immunity(immunities_amount):
	current_immunities += immunities_amount
	shield.visible = true

func speed_up(speed_increase, speed_increase_duration):
	speed += speed_increase
	speed_up_timer.wait_time = speed_increase_duration
	
	aura.modulate = Color("yellow")
	aura.visible = true
	
	speed_up_timer.start()
	await speed_up_timer.timeout
	
	speed -= speed_increase
	aura.visible = false
	
func damage_up(damage_increase, damage_increase_duration):
	damage += damage_increase
	damage_up_timer.wait_time = damage_increase_duration
	
	aura.modulate = Color("orange")
	aura.visible = true
	
	damage_up_timer.start()
	await damage_up_timer.timeout
	
	damage -= damage_increase
	aura.visible = false
	
