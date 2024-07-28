extends Control

@onready var health_bar = $HealthBar
@onready var shield_bar = $ShieldBar

func setMaxHealth(max_health: int):
	health_bar.max_value = max_health

func updateHealth(health: int):
	health_bar.value = health
	
func setMaxShield(max_shield: int):
	shield_bar.max_value = max_shield

func updateShield(shield: int):
	shield_bar.value = shield
