extends Area2D

@export var itemResource: InventoryItem
@onready var inventory: SlotsContainer = preload("res://assets/resources/inventory/player_inventory.tres")
@onready var hotbar: SlotsContainer = preload("res://assets/resources/inventory/player_hotbar.tres")
@onready var label = $Label

var canPick = false
const PICKUP_KEY = 'E'

func _ready():
	set_process_input(false)
	label.text = "["+PICKUP_KEY+"]"
	label.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		label.visible = true
		canPick = true
		set_process_input(true)

func _on_body_exited(body):
	if body.name == "Player":
		label.visible = false
		canPick = false
		set_process_input(false)

func _input(event):
	if event.is_action_pressed("pickup_item") and canPick:
		if hotbar.has_space() && itemResource.type == itemResource.CollectableType.POTION:
			hotbar.insert(itemResource)
			queue_free()
		elif inventory.has_space():
			inventory.insert(itemResource)
			queue_free()
		else:
			pass
