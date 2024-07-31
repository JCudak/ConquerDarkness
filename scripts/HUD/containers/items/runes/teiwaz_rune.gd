class_name TeiwazRune extends Rune

@export var cooldown_reduction = 0.05 

func activate(player: Player):
	player.attack_cooldown -= cooldown_reduction
	
func deactivate(player: Player):
	player.attack_cooldown += cooldown_reduction
