extends Panel
@onready var background: Sprite2D = $Background
@onready var itemSprite: Sprite2D  = $CenterContainer/Panel/item

func update(item: InventoryItem):
	if!item:
		background.frame = 0
		itemSprite.visible = false
	else:
		background.frame = 1
		itemSprite.visible = true
		itemSprite.texture = item.texture
