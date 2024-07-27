extends Node2D

@onready var healthAndShieldGui = $CanvasLayer/HUD/HpAndShieldGui
@onready var player = $Player

func _ready():
	healthAndShieldGui.setMaxHealth(player.maxHealth)
	healthAndShieldGui.updateHealth(player.currentHealth)
	healthAndShieldGui.setMaxShield(player.maxShield)
	healthAndShieldGui.updateShield(player.currentShield)
	player.healthChanged.connect(healthAndShieldGui.updateHealth)

func _process(delta):
	pass
