extends Node2D

@onready var healthBar = $SubViewportContainer/LightView/TileMap/CanvasLayer/healthBar
@onready var player = $SubViewportContainer/LightView/Player

func _ready():
	healthBar.setMaxHealth(player.maxHealth)
	healthBar.updateHealth(player.currentHealth)
	player.healthChanged.connect(healthBar.updateHealth)

func _process(delta):
	pass
