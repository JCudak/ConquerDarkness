class_name DamagePotion extends InventoryItem

@export var damage_increase: int = 5
@export var damage_increase_duration: int = 10

func use(player: Player):
	player.damage_up(damage_increase, damage_increase_duration)
