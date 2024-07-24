extends HBoxContainer

@onready var HealthGuiClass = preload("res://assets/scenes/hearth_gui.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setMaxHealth(maxH :int):
	for i in range(maxH):
		var health = HealthGuiClass.instantiate()
		add_child(health)
	
func updateHealth(currentHealth: int):
	var health = get_children()
	
	for i in range(currentHealth):
		health[i].update(true)
	
	for i in range(currentHealth, health.size()):
		health[i].update(false)
