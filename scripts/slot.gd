extends Button
@onready var background: Sprite2D = $Background
@onready var container: CenterContainer = $CenterContainer

@onready var inventory = preload("res://assets/resources/inventory/player_inventory.tres")

var itemGui: ItemGui
var index: int

func insert(ig: ItemGui):
	itemGui = ig
	background.frame = 1
	container.add_child(itemGui)
	
	if !itemGui.inventorySlot:
		return
	
	inventory.insertSlot(index, itemGui.inventorySlot)

func takeItem():
	var item = itemGui
	
	inventory.removeSlot(itemGui.inventorySlot)
	
	container.remove_child(itemGui)
	itemGui = null
	background.frame = 0
	
	return item

func isEmpty():
	return !itemGui
