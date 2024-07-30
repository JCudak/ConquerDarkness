extends Node2D


@onready var player = $SubViewportContainer/LightView/Player
@onready var lights = $SubViewportContainer/LightView/Lights
@onready var healthAndShieldGui = $CanvasLayer/HUD/HpAndShieldGui

func _ready():
	healthAndShieldGui.setMaxHealth(player.maxHealth)
	healthAndShieldGui.updateHealth(player.currentHealth)
	healthAndShieldGui.setMaxShield(player.maxShield)
	healthAndShieldGui.updateShield(player.currentShield)
	player.healthChanged.connect(healthAndShieldGui.updateHealth)
	player.shieldChanged.connect(healthAndShieldGui.updateShield)
	for torch in lights.get_children():
		torch.enteredLight.connect(player.torch_area_entered)
		torch.exitedLight.connect(player.torch_area_exited)

func _process(delta):
	pass
