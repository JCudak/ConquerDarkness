extends Control
@onready var play = $MarginContainer/VBoxContainer/VBoxContainer2/Play/NinePatchRect/Label
@onready var settings = $MarginContainer/VBoxContainer/VBoxContainer2/Settings/NinePatchRect/Label
@onready var quit = $MarginContainer/VBoxContainer/VBoxContainer2/Quit/NinePatchRect/Label

func _ready():
	play.text = "play"
	settings.text = "settings"
	quit.text = "quit"

func _on_play_pressed():
	get_tree().change_scene_to_file("res://assets/scenes/level_manager.tscn")


func _on_settings_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()

