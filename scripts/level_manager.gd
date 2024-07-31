class_name LevelManager extends Node2D

# Preload your levels
@onready var levels = [preload("res://assets/scenes/level.tscn"), preload("res://assets/scenes/level.tscn"), preload("res://assets/scenes/level.tscn")]
var current_level_instance = null
var current_level: int = 0
var player_data = {health = 100, max_health = 100, shield = 0, max_shield = 50}

func _ready():
	next_level()

func next_level():
	switch_level(levels[current_level])
	current_level+=1

func switch_level(level_scene):
	if current_level_instance:
		save_player_data()
		current_level_instance.queue_free()
	
	current_level_instance = level_scene.instantiate()
	add_child(current_level_instance)
	var exit_node = current_level_instance.get_node("SubViewportContainer/LightView/Lights/Exit")
	exit_node.next_level.connect(next_level)
	
	var player = current_level_instance.get_node("SubViewportContainer/LightView/Player")
	var healthAndShieldGui = current_level_instance.get_node("CanvasLayer/HUD/HpAndShieldGui")
	player.maxHealth = player_data["max_health"]
	player.currentHealth = player_data["health"]
	player.currentShield = player_data["shield"]
	player.maxShield = player_data["max_shield"]
	healthAndShieldGui.setMaxHealth(player.maxHealth)
	healthAndShieldGui.setMaxShield(player.maxShield)
	player.emit_signal("healthChanged", player.currentHealth)
	player.emit_signal("shieldChanged", player.currentShield)

func save_player_data():
	var player = current_level_instance.get_node("SubViewportContainer/LightView/Player")
	player_data["health"] = player.currentHealth
	player_data["max_health"] = player.maxHealth
	player_data["shield"] = player.currentShield
	player_data["max_shield"] = player.maxShield
