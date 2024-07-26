extends SlotsContainerGui

func _ready():
	containerType = 0
	slots = $NinePatchRect/HBoxContainer.get_children()
	connect_slots()
	hotbar.updated.connect(update)
	for i in range(slots.size()):
		slots[i].set_amount_label(str(i + 1) + " ")
		slots[i].background.frame = 3
	update()

func update():
	for i in range(min(hotbar.slots.size(), slots.size())):
		
		var inventorySlot: InventorySlot = hotbar.slots[i]
		
		if !inventorySlot.item: 
			slots[i].clear()
			continue
		
		var itemGui: ItemGui = slots[i].itemGui
		if !itemGui:
			itemGui = ItemGuiClass.instantiate()
			slots[i].insert(itemGui)
		
		itemGui.inventorySlot = inventorySlot
		itemGui.update()

func _unhandled_input(event):
	if event.is_action_pressed("quickslot_1"):
		use_item_at_index(0)
	if event.is_action_pressed("quickslot_2"):
		use_item_at_index(1)
	if event.is_action_pressed("quickslot_3"):
		use_item_at_index(2)

func use_item_at_index(index:int):
	if index < 0 || index >= hotbar.slots.size() || !hotbar.slots[index].item: return
	use_item.emit(hotbar.slots[index].item)
	hotbar.remove_at_index(index)
