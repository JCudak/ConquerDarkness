extends Resource

class_name Inventory
signal updated

@export var slots: Array[InventorySlot]

func insert(item: InventoryItem):
	for i in range(slots.size()):
		if!slots[i].item:
			slots[i].item = item
			updated.emit()
			break

func has_space():
	for i in range(slots.size()):
		if!slots[i].item:
			return true
	return false

func removeSlot(inventorySlot: InventorySlot):
	var index = slots.find(inventorySlot)
	if index < 0: return
	
	slots[index] = InventorySlot.new()


func insertSlot(index: int, inventorySlot: InventorySlot):
	slots[index] = inventorySlot
