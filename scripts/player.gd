extends CharacterBody2D

class_name Player

signal healthChanged

const SPEED_REDUCTION = 12
@export var speed = 100.0
@export var burst_speed = 250.0
@onready var sprite_2d = $Sprites/Sprite2D
@onready var sword = $Sprites/Sword
@onready var sprites = $Sprites
@onready var animation = $AnimationPlayer
@export var slotsContainer: Node

@export var maxHealth = 3
@onready var currentHealth: int = maxHealth
@onready var deathTimer = $deathTimer
@onready var hurtTimer = $hurtTimer
@onready var effects = $Effects

var is_dead = false
var is_hurt = false
var is_attacking = false

var attackDirection: Vector2
var targetPosition: Vector2

func _ready():
	slotsContainer.get_node("HotbarGUI").use_item.connect(use_item)
	effects.play("RESET")

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
		is_hurt = true
		
		currentHealth -= 1
		
		effects.play("hurtBlink")
		
		animation.play("damaged")
		
		hurtTimer.start()
		await hurtTimer.timeout
		effects.play("RESET")
		
		emit_signal("healthChanged", currentHealth) # Sends signal to health_bar.gd

func attack_animation():
	if Input.is_action_just_pressed("attack"):
		if is_attacking: 
			return
		
		is_attacking = true
		targetPosition = get_global_mouse_position()
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
