class_name Slot extends Button

enum CollectableType {RUNE, POTION}
@onready var background: Sprite2D = $Background
@onready var container: CenterContainer = $CenterContainer
@onready var amount_label = $Label

@onready var inventory = preload("res://assets/resources/inventory/player_inventory.tres")
@onready var hotbar = preload("res://assets/resources/inventory/player_hotbar.tres")
@onready var rune_equip = preload("res://assets/resources/inventory/player_rune_equip.tres")
@onready var details_panel = $DetailsPanel
@onready var usage_panel = $UsagePanel
@onready var use_button = $UsagePanel/NinePatchRect/VBoxContainer/UseButton
@onready var item_name_label = $DetailsPanel/NinePatchRect/Label

var itemGui: ItemGui
var index: int
var containerType: int

signal right_clicked
signal use_button_clicked
signal trash_button_clicked

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


func _gui_input(event):
	if event.is_action_pressed("right_click"):
			emit_signal("right_clicked")

func _on_mouse_entered():
	if itemGui and itemGui.inventorySlot.item:
		set_item_name_label(itemGui.inventorySlot.item.name)
		details_panel.visible = true


func _on_mouse_exited():
	details_panel.visible = false

func set_usage_panel_visibility(visible: bool):
	usage_panel.visible = visible
	if itemGui and itemGui.inventorySlot.item.type == CollectableType.RUNE:
		use_button.disabled = true
	else:
		use_button.disabled = false


func _on_use_button_pressed():
	use_button_clicked.emit()
	
	take_item()
	usage_panel.visible = false


func _on_trash_button_pressed():
	take_item()
	usage_panel.visible = false

func _input(event):
	
	if event is InputEventMouseButton and event.pressed:
		if not get_rect().has_point(event.position) or not usage_panel.get_rect().has_point(event.position):
			#set_usage_panel_visibility(false)
			pass
