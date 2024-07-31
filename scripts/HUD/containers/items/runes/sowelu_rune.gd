class_name SoweluRune extends Rune

@export var vision_increase: float = 0.1

func activate(player: Player):
	player.point_light_2d.texture_scale += vision_increase
	
func deactivate(player: Player):
	player.point_light_2d.texture_scale -= vision_increase
