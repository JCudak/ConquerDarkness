class_name Exit extends Area2D

@onready var label = $Label
@onready var torch = $Torch

var canInteract = false
const INTERACT_KEY = 'E'
signal next_level

func _ready():
	set_process_input(false)
	label.text = "["+INTERACT_KEY+"]"
	label.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		label.visible = true
		canInteract = true
		set_process_input(true)

func _on_body_exited(body):
	if body.name == "Player":
		label.visible = false
		canInteract = false
		set_process_input(false)

func _input(event):
	if event.is_action_pressed("interact") and canInteract:
		next_level.emit()
