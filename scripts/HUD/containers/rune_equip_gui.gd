extends SlotsContainerGui

func _ready():
	containerType = 2
	slots = $NinePatchRect.get_children()
	connect_slots()
	rune_equip.updated.connect(update)
	update()
	for slot in slots:
		slot.background.frame = 2

func update():
	for i in range(min(rune_equip.slots.size(), slots.size())):
		var inventorySlot: InventorySlot = rune_equip.slots[i]
		
		if !inventorySlot.item: continue
		
		var itemGui: ItemGui = slots[i].itemGui
		if !itemGui:
			itemGui = ItemGuiClass.instantiate()
			slots[i].insert(itemGui)
		
		itemGui.inventorySlot = inventorySlot
		itemGui.update()
