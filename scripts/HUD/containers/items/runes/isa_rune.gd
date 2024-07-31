class_name IsaRune extends Rune

@export var slow_power: int = 5

func activate(player: Player):
	player.slow_power += slow_power
	
func deactivate(player: Player):
	player.slow_power -= slow_power
