class_name SpeedPotion extends InventoryItem

@export var speed_increase: int = 50
@export var speed_increase_duration: int = 10

func use(player: Player):
	player.speed_up(speed_increase, speed_increase_duration)
