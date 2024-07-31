extends CanvasLayer

@onready var inventory = $HUD/InventoryGUI
@onready var rune_equip = $HUD/RuneEquipGUI
@onready var hud = $HUD
@onready var settings = $InputSettings
@export var camera_2d: Camera2D

var is_map_open: bool = false

func _ready():
	inventory.close()
	rune_equip.close()
	inventory.locked = true
	settings.close()
	
func _input(event):
	if event.is_action_pressed("toggle_inventory") and not get_tree().paused:
		if inventory.isOpen:
			inventory.locked = true
			inventory.close()
			rune_equip.close()
		else:
			inventory.locked = false
			inventory.open()
			rune_equip.open()
	
	if event.is_action_pressed("toggle_map"):
		if is_map_open:
			get_tree().paused = false
			is_map_open = false
			camera_2d.zoom = camera_2d.zoom*3
			hud.visible = true
		elif not get_tree().paused:
			is_map_open = true
			camera_2d.zoom = camera_2d.zoom/3
			get_tree().paused = true
			hud.visible = false
