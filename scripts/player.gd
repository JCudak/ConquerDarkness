extends CharacterBody2D

class_name Player

signal healthChanged

const SPEED_REDUCTION = 12
@export var speed = 100.0
@export var burst_speed = 250.0
@onready var animated_sprite_2d = $AnimatedSprite2D
@export var inventory: Inventory

@export var maxHealth = 3
@onready var currentHealth: int = maxHealth
@onready var deathTimer = $deathTimer
@onready var hurtTimer = $hurtTimer
@onready var effects = $Effects

var is_dead = false
var is_hurt = false

func _ready():
	effects.play("RESET")

func _physics_process(delta):
	die()
	update_animation()
	move_and_slide()

func update_animation():
	if is_dead:
		return
	if is_hurt:
		return
	
	if (absf(velocity.x) > 1.0 || absf(velocity.y) > 1.0):
		animated_sprite_2d.play("running")
	else:
		animated_sprite_2d.play("default")
	
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
	
	animated_sprite_2d.flip_h = velocity.x < 0

func die():
	if currentHealth <= 0 and not is_dead:
		is_dead = true
		effects.play("RESET")
		animated_sprite_2d.play("death")
		deathTimer.start()
		await deathTimer.timeout
		get_tree().change_scene_to_file("res://assets/scenes/game_over.tscn")

func _on_hurt_box_area_entered(area):
	if area.name == "hitBox":
		is_hurt = true
		currentHealth -= 1
		animated_sprite_2d.play("damaged")
		effects.play("hurtBlink")
		hurtTimer.start()
		await hurtTimer.timeout
		effects.play("RESET")
		is_hurt = false
		healthChanged.emit(currentHealth)

