extends Node2D


@onready var player = $SubViewportContainer/LightView/Player
@onready var healthAndShieldGui = $CanvasLayer/HUD/HpAndShieldGui


func _ready():
	healthAndShieldGui.setMaxHealth(player.maxHealth)
	healthAndShieldGui.updateHealth(player.currentHealth)
	healthAndShieldGui.setMaxShield(player.maxShield)
	healthAndShieldGui.updateShield(player.currentShield)
	player.healthChanged.connect(healthAndShieldGui.updateHealth)
	player.shieldChanged.connect(healthAndShieldGui.updateShield)

func _process(delta):
	pass
