class_name RerthRune extends Rune

@export var drop_chance_increase: float = 0.1 

func activate(player: Player):
	player.world.rune_plus_spawn_chance += drop_chance_increase

func deactivate(player: Player):
	player.world.rune_plus_spawn_chance -= drop_chance_increase
