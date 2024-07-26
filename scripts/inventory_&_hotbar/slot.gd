extends Button
@onready var background: Sprite2D = $Background
@onready var container: CenterContainer = $CenterContainer

@onready var inventory = preload("res://assets/resources/inventory/player_inventory.tres")
@onready var hotbar = preload("res://assets/resources/inventory/player_hotbar.tres")

var itemGui: ItemGui
var index: int
var containerType: int

func insert(ig: ItemGui):
	itemGui = ig
	background.frame = 1
	container.add_child(itemGui)
	
	if !itemGui.inventorySlot:
		return
	
	if containerType == 0:
		hotbar.insertSlot(index, itemGui.inventorySlot)
	elif containerType == 1:
		inventory.insertSlot(index, itemGui.inventorySlot)
	else:
		print("WTF?")

func takeItem():
	var item = itemGui
	
	if containerType == 0:
		hotbar.removeSlot(itemGui.inventorySlot)
	elif containerType == 1:
		inventory.removeSlot(itemGui.inventorySlot)
	else:
		print("WTF?")
		
	container.remove_child(itemGui)
	itemGui = null
	background.frame = 0
	
	return item

func isEmpty():
	return !itemGui
