extends CanvasLayer

@onready var inventory = $SlotsContainers/InventoryGUI
@onready var rune_equip = $SlotsContainers/RuneEquipGUI
@onready var settings = $InputSettings

func _ready():
	inventory.close()
	rune_equip.close()
	inventory.locked = true
	settings.close()
	
func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		if inventory.isOpen:
			inventory.locked = true
			inventory.close()
			rune_equip.close()
		else:
			inventory.locked = false
			inventory.open()
			rune_equip.open()
	if event.is_action_pressed("toggle_settings"):
		if settings.isOpen:
			settings.close()
		else:
			settings.open()
