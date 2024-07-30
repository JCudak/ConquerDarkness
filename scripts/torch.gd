extends Sprite2D

signal enteredLight
signal exitedLight

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_light_range_area_2d_area_entered(area):
	if area.name == "PlayerArea2D":
		emit_signal("enteredLight")


func _on_light_range_area_2d_area_exited(area):
	if area.name == "PlayerArea2D":
		emit_signal("exitedLight")
