class_name LevelManager extends Node2D

# Preload your levels
@onready var levels: Array = [
	preload("res://assets/scenes/dungeon/level.tscn"), 
	preload("res://assets/scenes/dungeon/level.tscn"), 
	preload("res://assets/scenes/dungeon/level.tscn")
	]
var current_level_instance = null
var current_level: int = 0
var player_data = {health = 100, max_health = 100, shield = 0, max_shield = 50}

const PLAYER_HOTBAR = preload("res://assets/resources/inventory/player_hotbar.tres")
const PLAYER_INVENTORY = preload("res://assets/resources/inventory/player_inventory.tres")
const PLAYER_RUNE_EQUIP = preload("res://assets/resources/inventory/player_rune_equip.tres")

func _ready():
	reset_all()
	next_level()

func next_level():
	if current_level >= levels.size():
		get_tree().change_scene_to_file("res://assets/scenes/menus/win_menu.tscn")
	else:
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

func reset_all():
	current_level = 0
	player_data = {health = 100, max_health = 100, shield = 0, max_shield = 50}
	current_level_instance = null
	PLAYER_HOTBAR.clear_all_slots()
	PLAYER_INVENTORY.clear_all_slots()
	PLAYER_RUNE_EQUIP.clear_all_slots()
