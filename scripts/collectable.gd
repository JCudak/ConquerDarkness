extends Area2D

@export var itemResource: InventoryItem
@onready var inventory: Inventory = preload("res://assets/resources/inventory/player_inventory.tres")

func _on_body_entered(body):
	if(body.name == "Player"):
		inventory.insert(itemResource)
		queue_free()
