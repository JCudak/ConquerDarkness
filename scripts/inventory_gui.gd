extends Control

var isOpen: bool = false

@onready var inventory: Inventory = preload("res://assets/resources/inventory/player_inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func _ready():
	inventory.updated.connect(update)
	update()

func update():
	for i in range(min(inventory.items.size(), slots.size())):
		slots[i].update(inventory.items[i])

func open():
	visible=true
	isOpen=true

func close():
	visible=false
	isOpen=false
