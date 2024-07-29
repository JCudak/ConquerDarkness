class_name UrusRune extends Rune

func activate(player: Player):
	player.rune_damage_change(1)
	
func deactivate(player: Player):
	player.rune_damage_change(-1)
	pass
