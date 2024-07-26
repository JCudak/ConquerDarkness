extends SlotsContainerGui

func _ready():
	containerType = 0
	slots = $NinePatchRect/HBoxContainer.get_children()
	connectSlots()
	hotbar.updated.connect(update)
	update()

func update():
	for i in range(min(hotbar.slots.size(), slots.size())):
		var inventorySlot: InventorySlot = hotbar.slots[i]
		
		if !inventorySlot.item: continue
		
		var itemGui: ItemGui = slots[i].itemGui
		if !itemGui:
			itemGui = ItemGuiClass.instantiate()
			slots[i].insert(itemGui)
		
		itemGui.inventorySlot = inventorySlot
		itemGui.update()
