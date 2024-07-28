class_name ImmunityPotion extends InventoryItem

@export var immunities_amount: int = 1

func use(player: Player):
	player.add_immunity(immunities_amount)
