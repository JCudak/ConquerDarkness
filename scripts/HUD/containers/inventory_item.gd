extends Resource

class_name InventoryItem

enum CollectableType {RUNE, POTION}

@export var name: String = ""
@export var type: CollectableType
@export var texture: Texture2D


func use(player: Player):
	pass
