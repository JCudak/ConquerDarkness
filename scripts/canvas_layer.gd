extends CanvasLayer

@onready var inventory = $InventoryGUI
@onready var settings = $InputSettings

func _ready():
	inventory.close()
	settings.close()
	
func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		if inventory.isOpen:
			inventory.close()
		else:
			inventory.open()
	if event.is_action_pressed("toggle_settings"):
		if settings.isOpen:
			settings.close()
		else:
			settings.open()
