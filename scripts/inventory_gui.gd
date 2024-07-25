extends Control

var isOpen: bool = false

@onready var inventory: Inventory = preload("res://assets/resources/inventory/player_inventory.tres")
@onready var ItemGuiClass = preload("res://assets/scenes/item_gui.tscn")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var itemInHand: ItemGui
var oldIndex: int = -1
var locked: bool = false

func _ready():
	connectSlots()
	inventory.updated.connect(update)
	update()

func connectSlots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		var callable = Callable(onSlotClicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventorySlot: InventorySlot = inventory.slots[i]
		
		if !inventorySlot.item: continue
		
		var itemGui: ItemGui = slots[i].itemGui
		if !itemGui:
			itemGui = ItemGuiClass.instantiate()
			slots[i].insert(itemGui)
		
		itemGui.inventorySlot = inventorySlot
		itemGui.update()

func open():
	visible=true
	isOpen=true

func close():
	visible=false
	isOpen=false

func onSlotClicked(slot):
	if locked: return
	
	if itemInHand:
		if slot.isEmpty():
			insertItemInSlot(slot)
			return
		else:
			replaceItemInSlot(slot)
			return
	else:
		if !slot.isEmpty():
			takeItemFromSlot(slot)

func takeItemFromSlot(slot):
	itemInHand = slot.takeItem()
	add_child(itemInHand)
	updateItemInHand()
	
	oldIndex = slot.index
	
func replaceItemInSlot(slot):
	var item = slot.takeItem()
	insertItemInSlot(slot)
	
	itemInHand = item
	add_child(itemInHand)
	updateItemInHand()

func insertItemInSlot(slot):
	var item = itemInHand
	remove_child(itemInHand)
	itemInHand = null
	slot.insert(item)
	oldIndex = -1

func updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2

func putItemBack():
	locked = true
	if oldIndex < 0:
		var emptySlots = slots.filter(func(s): return s.isEmpty())
		if emptySlots.is_empty(): return
		
		oldIndex = emptySlots[0].index
	
	var targetSlot = slots[oldIndex]
	
	var tween = create_tween()
	var targetPosition = targetSlot.global_position + Vector2(10,10) # I had to add this cause targetSlot.size/2 didn't work
	tween.tween_property(itemInHand, "global_position", targetPosition, 0.2)
	
	await tween.finished	
	insertItemInSlot(targetSlot)
	locked = false

func _input(event):
	if itemInHand and !locked and Input.is_action_pressed("right_click"):
		putItemBack()
		
	updateItemInHand()
