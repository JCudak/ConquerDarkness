extends Control

class_name SlotsContainerGui

var isOpen: bool = false

@onready var inventory: SlotsContainer = preload("res://assets/resources/inventory/player_inventory.tres")
@onready var hotbar: SlotsContainer = preload("res://assets/resources/inventory/player_hotbar.tres")
@onready var ItemGuiClass = preload("res://assets/scenes/inventory_&_hotbar/item_gui.tscn")
@onready var slots: Array
@export var parent_node: Node

static var itemInHand: ItemGui
static var oldIndex: int = -1
static var oldContainerType: int = -1
static var locked: bool = false
static var lastSlot: Node
var containerType: int = -1

func connectSlots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		slot.containerType = containerType
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
			lastSlot = null
			return
		else:
			replaceItemInSlot(slot)
			return
	else:
		if !slot.isEmpty():
			takeItemFromSlot(slot)

func takeItemFromSlot(slot):
	itemInHand = slot.takeItem()
	itemInHand.scale = Vector2(4,4)
	parent_node.add_child(itemInHand)
	updateItemInHand()
	
	oldIndex = slot.index
	oldContainerType = slot.containerType
	lastSlot = slot
	
func replaceItemInSlot(slot):
	var item = slot.takeItem()
	insertItemInSlot(slot)
	
	itemInHand = item
	itemInHand.scale = Vector2(4,4)
	parent_node.add_child(itemInHand)
	updateItemInHand()

func insertItemInSlot(slot):
	var item = itemInHand
	parent_node.remove_child(itemInHand)
	itemInHand.scale = Vector2(1,1)
	itemInHand = null
	slot.insert(item)
	oldIndex = -1
	oldContainerType = -1

func updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2


func putItemBack():
	locked = true	
	var targetSlot = lastSlot
	
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
