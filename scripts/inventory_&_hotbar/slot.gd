extends Button
@onready var background: Sprite2D = $Background
@onready var container: CenterContainer = $CenterContainer
@onready var label = $Label

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
		hotbar.insert_slot(index, itemGui.inventorySlot)
	elif containerType == 1:
		inventory.insert_slot(index, itemGui.inventorySlot)
	else:
		print("WTF?")

func take_item():
	var item = itemGui
	
	if containerType == 0:
		hotbar.remove_slot(itemGui.inventorySlot)
	elif containerType == 1:
		inventory.remove_slot(itemGui.inventorySlot)
	else:
		print("WTF?")
	
	clear()
	
	return item

func is_empty():
	return !itemGui

func set_label(txt):
	label.text = txt

func clear():
	if itemGui:
		container.remove_child(itemGui)
		itemGui = null
		
	background.frame = 0
