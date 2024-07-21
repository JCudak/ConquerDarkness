extends CharacterBody2D

class_name Player

@export var speed = 100.0
const SPEED_REDUCTION = 12
@onready var animated_sprite_2d = $AnimatedSprite2D
@export var inventory: Inventory

func _physics_process(delta):
	
	if (absf(velocity.x) > 1.0 || absf(velocity.y) > 1.0):
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "default"
	
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

	move_and_slide()
	
	animated_sprite_2d.flip_h = velocity.x < 0
