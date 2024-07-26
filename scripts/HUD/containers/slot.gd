class_name Slot extends Button
@onready var background: Sprite2D = $Background
@onready var container: CenterContainer = $CenterContainer
@onready var amount_label = $Label

@onready var inventory = preload("res://assets/resources/inventory/player_inventory.tres")
@onready var hotbar = preload("res://assets/resources/inventory/player_hotbar.tres")
@onready var rune_equip = preload("res://assets/resources/inventory/player_rune_equip.tres")
@onready var details_panel = $DetailsPanel
@onready var item_name_label = $DetailsPanel/NinePatchRect/Label

var itemGui: ItemGui
var index: int
var containerType: int

func insert(ig: ItemGui):
	itemGui = ig
	
	if containerType == 1:
		background.frame = 1
	
	container.add_child(itemGui)
	
	if !itemGui.inventorySlot:
		return
	
	if containerType == 0:
		hotbar.insert_slot(index, itemGui.inventorySlot)
	elif containerType == 1:
		inventory.insert_slot(index, itemGui.inventorySlot)
	elif containerType == 2:
		rune_equip.insert_slot(index, itemGui.inventorySlot)
	else:
		print("WTF?")

func take_item():
	var item = itemGui
	
	if containerType == 0:
		hotbar.remove_slot(itemGui.inventorySlot)
	elif containerType == 1:
		inventory.remove_slot(itemGui.inventorySlot)
	elif containerType == 2:
		rune_equip.remove_slot(itemGui.inventorySlot)
	else:
		print("WTF?")
	
	clear()
	
	return item

func is_empty():
	return !itemGui

func set_item_name_label(txt):
	item_name_label.text = txt
	
func set_amount_label(txt):
	amount_label.text = txt

func clear():
	if itemGui:
		container.remove_child(itemGui)
		itemGui = null
	if containerType == 1:
		background.frame = 0


func _on_mouse_entered():
	if itemGui and itemGui.inventorySlot.item:
		set_item_name_label(itemGui.inventorySlot.item.name)
		details_panel.visible = true


func _on_mouse_exited():
	details_panel.visible = false

