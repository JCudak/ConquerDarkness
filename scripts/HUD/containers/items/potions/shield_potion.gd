class_name ShieldPotion extends InventoryItem

@export var shield_increase: int = 1

func use(player: Player):
	player.add_shield(shield_increase)
