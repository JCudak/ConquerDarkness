extends Resource

class_name SlotsContainer
signal updated

@export var slots: Array[InventorySlot]

func insert(item: InventoryItem):
	for slot in slots:
		if!slot.item:
			slot.item = item
			updated.emit()
			break

func has_space():
	for i in range(slots.size()):
		if!slots[i].item:
			return true
	return false

func remove_slot(inventorySlot: InventorySlot):
	var index = slots.find(inventorySlot)
	if index < 0: return
	
	remove_at_index(index)

func remove_at_index(index: int):
	slots[index] = InventorySlot.new()
	updated.emit()

func insert_slot(index: int, inventorySlot: InventorySlot):
	slots[index] = inventorySlot
	updated.emit()
