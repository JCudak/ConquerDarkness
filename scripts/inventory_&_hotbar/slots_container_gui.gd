extends Control

class_name SlotsContainerGui

signal use_item
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

func connect_slots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		slot.containerType = containerType
		var callable = Callable(on_slot_clicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func open():
	visible=true
	isOpen=true

func close():
	visible=false
	isOpen=false

func on_slot_clicked(slot):
	if locked: return
	
	if itemInHand:
		if slot.is_empty():
			insert_item_in_slot(slot)
			lastSlot = null
			return
		else:
			replace_item_in_slot(slot)
			return
	else:
		if !slot.is_empty():
			take_item_from_slot(slot)

func take_item_from_slot(slot):
	itemInHand = slot.take_item()
	parent_node.add_child(itemInHand)
	update_item_in_hand()
	
	oldIndex = slot.index
	oldContainerType = slot.containerType
	lastSlot = slot
	
func replace_item_in_slot(slot):
	var item = slot.take_item()
	insert_item_in_slot(slot)
	
	itemInHand = item
	parent_node.add_child(itemInHand)
	update_item_in_hand()

func insert_item_in_slot(slot):
	var item = itemInHand
	parent_node.remove_child(itemInHand)
	itemInHand = null
	slot.insert(item)
	oldIndex = -1
	oldContainerType = -1

func update_item_in_hand():
	if !itemInHand: return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2


func put_item_back():
	locked = true	
	var targetSlot = lastSlot
	
	var tween = create_tween()
	var targetPosition = targetSlot.global_position + Vector2(10,10) # I had to add this cause targetSlot.size/2 didn't work
	tween.tween_property(itemInHand, "global_position", targetPosition, 0.2)
	
	await tween.finished	
	insert_item_in_slot(targetSlot)
	locked = false

func _input(event):
	if itemInHand and !locked and Input.is_action_pressed("right_click"):
		put_item_back()
		
	update_item_in_hand()
