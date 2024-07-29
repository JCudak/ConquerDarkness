class_name AlgizRune extends Rune

func activate(player: Player):
	player.add_rune("Algiz")
	
func deactivate(player: Player):
	player.remove_rune("Algiz")
