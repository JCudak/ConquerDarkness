extends Panel

class_name ItemGui

@onready var itemSprite: Sprite2D  = $item

var inventorySlot: InventorySlot

func update():
	if !inventorySlot or !inventorySlot.item: return
	
	itemSprite.visible = true
	itemSprite.texture = inventorySlot.item.texture
