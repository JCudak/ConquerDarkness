extends Control

class_name SlotsContainerGui

signal use_item
var isOpen: bool = false

enum CollectableType {RUNE, POTION}

@onready var inventory: SlotsContainer = preload("res://assets/resources/inventory/player_inventory.tres")
@onready var hotbar: SlotsContainer = preload("res://assets/resources/inventory/player_hotbar.tres")
@onready var rune_equip: SlotsContainer = preload("res://assets/resources/inventory/player_rune_equip.tres")
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
		var current_item_name = itemInHand.inventorySlot.item.name
		if !is_slot_valid(slot):
			return
		if slot.is_empty():
			if containerType == 2 && current_item_name == "Laguz Rune":
				return
			insert_item_in_slot(slot)
			lastSlot = null
			return
		else:
			if containerType == 2:
				if current_item_name == "Laguz Rune":
					parent_node.remove_child(itemInHand)
					itemInHand = null
					take_item_from_slot(slot)
					parent_node.remove_child(itemInHand)
					itemInHand = null
					update_item_in_hand()
				return
			replace_item_in_slot(slot)
	else:
		if !slot.is_empty() && containerType != 2:
			take_item_from_slot(slot)

func is_slot_valid(slot):
	var item_type = itemInHand.inventorySlot.item.type
	var container_type = slot.containerType

	if container_type == 1:
		return true
	elif container_type == 0 and item_type == CollectableType.POTION:
		return true
	elif container_type == 2 and item_type == CollectableType.RUNE:
		return true
	else:
		return false

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
	var targetSlot: Slot = lastSlot
	
	if !is_slot_valid(targetSlot):
		locked = false
		return
	
	var tween = create_tween()
	var targetPosition = targetSlot.global_position + Vector2(20,20) # I had to add this cause targetSlot.size/2 didn't work
	tween.tween_property(itemInHand, "global_position", targetPosition, 0.2)
	
	await tween.finished	
	insert_item_in_slot(targetSlot)
	locked = false

func _input(event):
	if itemInHand and !locked and Input.is_action_pressed("right_click"):
		put_item_back()
		
	update_item_in_hand()
