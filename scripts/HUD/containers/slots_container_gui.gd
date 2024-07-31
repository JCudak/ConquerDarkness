extends Control

class_name SlotsContainerGui

signal use_item
signal merge_item
var isOpen: bool = false

enum CollectableType {RUNE, POTION}

@onready var inventory: SlotsContainer = preload("res://assets/resources/inventory/player_inventory.tres")
@export var inventoryContainerGui: InventoryGui
@onready var hotbar: SlotsContainer = preload("res://assets/resources/inventory/player_hotbar.tres")
@onready var rune_equip: SlotsContainer = preload("res://assets/resources/inventory/player_rune_equip.tres")
@onready var ItemGuiClass = preload("res://assets/scenes/HUD/item_gui.tscn")
@onready var slots: Array
@export var parent_node: Node


# PLUS RUNES RESOURCES
const ALGIZ_RUNE_PLUS = preload("res://assets/resources/inventory/items/runes/algiz_rune_plus.tres")
const ISA_RUNE_PLUS = preload("res://assets/resources/inventory/items/runes/isa_rune_plus.tres")
const LAGUZ_RUNE_PLUS = preload("res://assets/resources/inventory/items/runes/laguz_rune_plus.tres")
const RERTH_RUNE_PLUS = preload("res://assets/resources/inventory/items/runes/rerth_rune_plus.tres")
const SOWELU_RUNE_PLUS = preload("res://assets/resources/inventory/items/runes/sowelu_rune_plus.tres")
const TEIWAZ_RUNE_PLUS = preload("res://assets/resources/inventory/items/runes/teiwaz_rune_plus.tres")
const URUS_RUNE_PLUS = preload("res://assets/resources/inventory/items/runes/urus_rune_plus.tres")

var PLUS_RUNES : Dictionary = {
	"Algiz Rune +": ALGIZ_RUNE_PLUS,
	"Isa Rune +":ISA_RUNE_PLUS, 
	"Laguz Rune +":LAGUZ_RUNE_PLUS,
	"Rerth Rune +":RERTH_RUNE_PLUS,
	"Sowelu Rune +":SOWELU_RUNE_PLUS,
	"Teiwaz Rune +":TEIWAZ_RUNE_PLUS,
	"Urus Rune +":URUS_RUNE_PLUS
}

static var itemInHand: ItemGui
static var oldIndex: int = -1
static var oldContainerType: int = -1
static var locked: bool = false
static var lastSlot: Slot
static var lastSlotRightClicked: Slot
var containerType: int = -1

func connect_slots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		slot.containerType = containerType
		
		# Connect the pressed signal
		var pressed_callable = Callable(on_slot_clicked)
		pressed_callable = pressed_callable.bind(slot)
		slot.pressed.connect(pressed_callable)
		
		# Connect the right_clicked signal
		var right_click_callable = Callable(on_slot_right_clicked)
		right_click_callable = right_click_callable.bind(slot)
		slot.right_clicked.connect(right_click_callable)
		
		var action_item_callable = Callable(on_action_item)
		action_item_callable = action_item_callable.bind(slot)
		slot.action_button_clicked.connect(action_item_callable)
		
		var unequip_callable = Callable(special_unequip)
		unequip_callable = unequip_callable.bind(slot)
		slot.trash_button_clicked.connect(unequip_callable)

func open():
	visible=true
	isOpen=true

func close():
	visible=false
	isOpen=false

func on_action_item(slot: Slot):
	if slot.get_resource().type == CollectableType.RUNE:
		for another_slot in inventoryContainerGui.slots:
			if another_slot != slot and !another_slot.is_empty() and another_slot.get_resource().name == slot.get_resource().name:
				var upgraded_name = slot.get_resource().name + " +"
				take_item_from_slot(another_slot)
				parent_node.remove_child(itemInHand)
				itemInHand = null
				var plus_rune = PLUS_RUNES[upgraded_name]
				inventory.insert(plus_rune)
				await get_tree().create_timer(0.25).timeout
				break
	else:
		use_item.emit(slot.get_resource())

func on_slot_right_clicked(slot):
	if slot.is_empty(): return
	lastSlotRightClicked = slot
	slot.set_usage_panel_visibility(true)
	slot.usage_panel.global_position = get_global_mouse_position()

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
				if current_item_name == "Laguz Rune +":
					put_item_back()
					await get_tree().create_timer(0.25).timeout
					take_item_from_slot(slot)
				elif current_item_name == "Laguz Rune":
					parent_node.remove_child(itemInHand)
					itemInHand = null
					take_item_from_slot(slot)
				else:
					replace_item_in_slot(slot)
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
	special_unequip(slot)
	itemInHand = slot.take_item()
	parent_node.add_child(itemInHand)
	update_item_in_hand()
	
	oldIndex = slot.index
	oldContainerType = slot.containerType
	lastSlot = slot
	
func special_equip(slot):
	pass
	
func special_unequip(slot):
	pass
	
func replace_item_in_slot(slot):
	special_unequip(slot)
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
	special_equip(slot)
	oldIndex = -1
	oldContainerType = -1

func update_item_in_hand():
	if !itemInHand: return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2

func put_item_back():
	locked = true	
	var targetSlot: Slot = lastSlot
	
	if !is_slot_valid(targetSlot) or lastSlot.containerType == 2:
		var emptySlots = inventoryContainerGui.slots.filter(func(s): return s.is_empty())
		if emptySlots.is_empty():
			locked = false
			return
		targetSlot = emptySlots[0]
	
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
	

func clear_all_slots():
	for slot in slots:
		slot.clear()
