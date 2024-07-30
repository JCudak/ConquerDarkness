extends CharacterBody2D

class_name Player

signal healthChanged
signal shieldChanged

const SPEED_REDUCTION: int = 12
@export var speed: float = 100.0
@onready var sprite_2d := $Sprites/Sprite2D

@onready var sprites := $Sprites
@onready var animation := $AnimationPlayer
@export var slotsContainer: Node

@export var maxHealth: int = 100
@export var maxShield: int = 50
@export var damage: int = 5

# rune variables
@export var damaged_time = 0.0
@export var Algiz_count = 0
@export var Algiz_shield = 2
@export var Algiz_time = 10 # in seconds

@onready var currentHealth: int = maxHealth
@onready var currentShield: int = 0
@onready var deathTimer := $Timers/DeathTimer
@onready var hurtTimer := $Timers/HurtTimer
@onready var speed_up_timer := $Timers/SpeedUpTimer
@onready var damage_up_timer := $Timers/DamageUpTimer
@onready var effects := $Effects
@onready var aura := $Sprites/Aura
@onready var shield := $Sprites/Shield
@onready var sword := $Sprites/Sword/SwordDamageArea/SwordDamageCollisionShape2D
@export var linked_position_node: Node2D

var is_dead: bool = false
var is_hurt: bool = false
var is_attacking: bool = false
var is_in_light: bool = false
var is_hurt_by_darkness: bool = false
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
		
		if container is RuneEquipGui:
			container.on_rune_equip.connect(on_rune_equip)
			container.on_rune_unequip.connect(on_rune_unequip)
			
	effects.play("RESET")

func _process(delta):
	if linked_position_node != null:
		linked_position_node.position = self.position

func _physics_process(delta):
	die()

	if is_dead:
		return
	
	if !is_in_light and !is_hurt_by_darkness:
		darkness_damage()
	
	update_animation()
	move_and_slide()
	attack_animation()
	update_timers(delta)

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
			damaged_time = 0
			var enemy: Enemy = area.get_parent()
			
			if currentShield > 0:
				currentShield -= enemy.damage
				emit_signal("shieldChanged", currentShield)
			else:
				currentHealth -= enemy.damage
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
		
		sword.disabled = false
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
		sword.disabled = true

func update_timers(delta):
	damaged_time += delta
	if Algiz_count > 0 and damaged_time > Algiz_time and damaged_time <= Algiz_time + delta:
		add_shield(Algiz_shield * Algiz_count)

func use_item(item: InventoryItem):
	item.use(self)

func on_rune_equip(rune: Rune):
	rune.activate(self)

func on_rune_unequip(rune: Rune):
	rune.deactivate(self)

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

func rune_damage_change(damage_increase):
	damage += damage_increase

func add_rune(rune: String):
	match rune:
		"Algiz":
			if Algiz_count == 0:
				damaged_time = 0.0
			Algiz_count += 1

func darkness_damage():
	is_hurt_by_darkness = true
	if currentShield > 0:
		currentShield -= 1
		emit_signal("shieldChanged", currentShield)
	else:
		currentHealth -= 1
		emit_signal("healthChanged", currentHealth)
	await get_tree().create_timer(1).timeout
	is_hurt_by_darkness = false

func torch_area_entered():
	is_in_light = true

func torch_area_exited():
	is_in_light = false
