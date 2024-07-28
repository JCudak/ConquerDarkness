class_name LifePotion extends InventoryItem

@export var health_increase: int = 1

func use(player: Player):
	player.heal(health_increase)
	pass
