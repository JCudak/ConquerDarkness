class_name UrusRune extends Rune

@export var damage_increase = 1

func activate(player: Player):
	player.damage += damage_increase
	
func deactivate(player: Player):
	player.damage += damage_increase
