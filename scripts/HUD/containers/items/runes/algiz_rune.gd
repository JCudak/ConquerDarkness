class_name AlgizRune extends Rune

@export var wait_time: float = 10.0

func activate(player: Player):
	player.algiz_count += 1
	player.update_algiz_time()
	
func deactivate(player: Player):
	player.algiz_count -= 1
	player.update_algiz_time()
